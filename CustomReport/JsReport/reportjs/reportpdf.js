var Stimulsoft;
(function (Stimulsoft) {
    var Report;
    (function (Report) {
        var Export;
        (function (Export) {
            var StiImageRotation = Stimulsoft.Report.Components.StiImageRotation;
            var StiString = Stimulsoft.System.StiString;
            var StiDashboardExport = Stimulsoft.Report.Dashboard.StiDashboardExport;
            var IStiDashboard = Stimulsoft.Report.Dashboard.IStiDashboard;
            var Color = Stimulsoft.System.Drawing.Color;
            var MemoryStream = Stimulsoft.System.IO.MemoryStream;
            var StiContainer = Stimulsoft.Report.Components.StiContainer;
            var StiBrush = Stimulsoft.Base.Drawing.StiBrush;
            var StiGradientBrush = Stimulsoft.Base.Drawing.StiGradientBrush;
            var StiGlareBrush = Stimulsoft.Base.Drawing.StiGlareBrush;
            var StiHatchBrush = Stimulsoft.Base.Drawing.StiHatchBrush;
            var StiGlassBrush = Stimulsoft.Base.Drawing.StiGlassBrush;
            var Hashtable = Stimulsoft.System.Collections.Hashtable;
            var StringBuilder = Stimulsoft.System.Text.StringBuilder;
            var StiText = Stimulsoft.Report.Components.StiText;
            var StiShape = Stimulsoft.Report.Components.StiShape;
            var StiRectanglePrimitive = Stimulsoft.Report.Components.StiRectanglePrimitive;
            var IStiFont = Stimulsoft.Report.Components.IStiFont;
            var IStiBrush = Stimulsoft.Report.Components.IStiBrush;
            var IStiTextBrush = Stimulsoft.Report.Components.IStiTextBrush;
            var IStiTextOptions = Stimulsoft.Report.Components.IStiTextOptions;
            var IStiBorder = Stimulsoft.Report.Components.IStiBorder;
            var XmlTextWriter = Stimulsoft.System.Xml.XmlTextWriter;
            var DateTime = Stimulsoft.System.DateTime;
            var IStiChart = Stimulsoft.Report.Chart.IStiChart;
            var StiImage = Stimulsoft.Report.Components.StiImage;
            var RectangleD = Stimulsoft.System.Drawing.Rectangle;
            var StiHorAlignment = Stimulsoft.Base.Drawing.StiHorAlignment;
            var StiVertAlignment = Stimulsoft.Base.Drawing.StiVertAlignment;
            var IStiExportImageExtended = Stimulsoft.Report.Components.IStiExportImageExtended;
            var StiCheckBox = Stimulsoft.Report.Components.StiCheckBox;
            var StiBarCode = Stimulsoft.Report.BarCodes.StiBarCode;
            var IStiTextHorAlignment = Stimulsoft.Report.Components.IStiTextHorAlignment;
            var FontStyle = Stimulsoft.System.Drawing.FontStyle;
            var StiPdfData = /** @class */ (function () {
                function StiPdfData(service) {
                    this.X = 0;
                    this.Y = 0;
                    this.Width = 0;
                    this.Height = 0;
                    this.Component = null;
                    this.service = null;
                    this.service = service;
                }
                Object.defineProperty(StiPdfData.prototype, "Right", {
                    get: function () {
                        return this.X + this.Width;
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiPdfData.prototype, "Top", {
                    get: function () {
                        return this.Y + this.Height;
                    },
                    enumerable: true,
                    configurable: true
                });
                return StiPdfData;
            }());
            Export.StiPdfData = StiPdfData;
            var StiImageData = /** @class */ (function () {
                function StiImageData() {
                }
                return StiImageData;
            }());
            var StiShadingData = /** @class */ (function () {
                function StiShadingData() {
                }
                return StiShadingData;
            }());
            var StiEditableObject = /** @class */ (function () {
                function StiEditableObject() {
                }
                return StiEditableObject;
            }());
            Export.StiEditableObject = StiEditableObject;
            var StiPdfExportService = /** @class */ (function (_super) {
                __extends(StiPdfExportService, _super);
                function StiPdfExportService() {
                    var _this = _super !== null && _super.apply(this, arguments) || this;
                    // Variables definition
                    _this.imageQuality = 0.75;
                    _this.imageResolutionMain = 1;
                    _this.imageResolutionMode = Export.StiImageResolutionMode.Auto;
                    _this.sw = null;
                    // private Stream stream2 = null;
                    _this.pageStream = null;
                    _this.imageList = null;
                    _this.imageCache = null;
                    _this.imageInterpolationTable = null;
                    _this.imageCacheIndexToList = null;
                    _this.imageInfoList = null;
                    _this.imageInfoCounter = 0;
                    // private Stimulsoft.System.Globalization.CultureInfo currentCulture = null;
                    // private Stimulsoft.System.Globalization.NumberFormatInfo currentNumberFormat = null;
                    _this.colorTable = Array.create(String, 256);
                    _this.alphaTable = Array.create(Boolean, 256);
                    _this.pdfFont = null;
                    _this.bidi = null;
                    _this.standardPdfFonts = true;
                    _this.embeddedFonts = false;
                    _this.useUnicodeMode = false;
                    _this.reduceFontSize = true;
                    _this.compressed = false;
                    _this.compressedFonts = false;
                    _this.encrypted = false;
                    _this.usePdfA = false;
                    _this.pdfComplianceMode = Export.StiPdfComplianceMode.None;
                    _this.exportRtfTextAsImage = false;
                    _this.autoPrint = Export.StiPdfAutoPrintMode.None;
                    _this.imageCompressionMethod = Export.StiPdfImageCompressionMethod.Jpeg;
                    _this.imageFormat = Export.StiImageFormat.Color;
                    _this.monochromeDitheringType = Export.StiMonochromeDitheringType.FloydSteinberg;
                    _this.allowEditable = Export.StiPdfAllowEditable.No;
                    _this.fontGlyphsReduceNotNeed = null;
                    _this.shadingArray = null;
                    _this.hatchArray = null;
                    _this.haveBookmarks = false;
                    _this.haveLinks = false;
                    _this.haveAnnots = false;
                    _this.haveTooltips = false;
                    _this.CodePage1252part80AF = [
                        0x20AC, 0x2022, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, 0x02C6, 0x2030, 0x0160, 0x2039, 0x0152, 0x2022, 0x017D, 0x2022,
                        0x2022, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014, 0x02DC, 0x2122, 0x0161, 0x203A, 0x0153, 0x2022, 0x017E, 0x0178
                    ];
                    _this.CodePage1252 = Array.create(Number, 256);
                    _this.hiToTwips = 0.72; // convert from hi(hundredths of inch) to points
                    _this.precision_digits_font = 3;
                    _this.pdfCKT = 0.55228; // pdf circle round koefficient
                    _this.IDValue = null;
                    _this.IDValueString = "";
                    _this.IDValueStringMeta = "";
                    _this.currentDateTime = "";
                    _this.currentDateTimeMeta = "";
                    _this.producerName = "Stimulsoft Reports";
                    _this.creatorName = "";
                    _this.keywords = "";
                    _this.keyLength = Export.StiPdfEncryptionKeyLength.Bit40;
                    _this.lastColorStrokeA = 0xFF;
                    _this.lastColorNonStrokeA = 0xFF;
                    _this.colorStack = null;
                    _this.info = null;
                    _this.haveDigitalSignature = false;
                    //        private Tools.StiPdfMetafileRender mfRender = null;
                    _this.pdfSecurity = null;
                    // PrintScaling property shows, how Acrobat Reader must to use margins of the printer.
                    // if true, then default settings of the Acrobat Reader will be used (usually "Fit to printer margin")
                    // else PrintScaling parameter of the pdf file will be set to None.
                    _this.printScaling = true;
                    _this.colorHash1 = new Hashtable();
                    _this.colorHash2 = new Hashtable();
                    _this._gsTable = null;
                    return _this;
                }
                Object.defineProperty(StiPdfExportService.prototype, "exportFormat", {
                    get: function () {
                        return Report.StiExportFormat.Pdf;
                    },
                    enumerable: true,
                    configurable: true
                });
                StiPdfExportService.prototype.exportTo = function (report, stream, settings) {
                    this.exportPdf1(report, stream, settings);
                };
                StiPdfExportService.prototype.exportToAsync = function (onExport, report, stream, settings) {
                    var _this = this;
                    var flate = settings.imageCompressionMethod == Export.StiPdfImageCompressionMethod.Flate;
                    Stimulsoft.Report.Export.StiExportImageHelper.convertAllImages(report, Stimulsoft.System.Drawing.Imaging.ImageFormat.Jpeg, flate)
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
                Object.defineProperty(StiPdfExportService.prototype, "multipleFiles", {
                   
                    get: function () {
                        return false;
                    },
                    enumerable: true,
                    configurable: true
                });
                StiPdfExportService.prototype.stringReplace = function (st, oldValue, newValue) {
                    oldValue = oldValue.replace(StiPdfExportService.regexEscape, "\\$1");
                    var reg = new RegExp(oldValue, "g");
                    return st.replace(reg, newValue);
                };
                /// Returns number of hatch in table of hatches.
                StiPdfExportService.prototype.getHatchNumber = function (brush) {
                    if (this.hatchArray.length > 0) {
                        for (var index = 0; index < this.hatchArray.length; index++) {
                            var tempBrush = this.hatchArray[index];
                            if ((brush.style == tempBrush.style) &&
                                (brush.backColor == tempBrush.backColor) &&
                                (brush.foreColor == tempBrush.foreColor)) {
                                return index;
                            }
                        }
                    }
                    // add hatch to table
                    this.hatchArray.add(brush);
                    return this.hatchArray.length - 1;
                };
                // int GetHatchNumber(HatchBrush brush)
                // {
                //    return GetHatchNumber(new StiHatchBrush(brush.HatchStyle, brush.ForegroundColor, brush.BackgroundColor));
                // }
                //#region Render procedures
                StiPdfExportService.prototype.addXref = function (num) {
                    var offs = this.sw.position;
                    this.xref[num] = offs.toString().sti.padLeft(10, "0") + " 00000 n";
                    this.currentObjectNumber = num;
                    this.currentGenerationNumber = 0;
                };
                // Convert numeric value to string
                StiPdfExportService.prototype.convertToString = function (value, precision) {
                    if (precision === void 0) { precision = 2; }
                    var numValue = Math.round2(value, precision);
                    return numValue.toString().sti.replaceAll(",", Stimulsoft.System.Globalization.CultureInfo.currentCulture.numberFormat.numberDecimalSeparator);
                };
                StiPdfExportService.convertToEscapeSequence = function (value) {
                    var escapeChars = [40, 41, 92, 13, 10, 8, 12];
                    var replaceChars = "()\\rnbf";
                    var flg;
                    var sb;
                    if (value == null) {
                        return "";
                    }
                    else {
                        sb = new StringBuilder();
                        for (var index = 0; index < value.length; index++) {
                            flg = false;
                            for (var index2 = 0; index2 < escapeChars.length; index2++) {
                                if (value.charCodeAt(index) == escapeChars[index2]) {
                                    sb.append("\\" + replaceChars[index2]);
                                    flg = true;
                                    break;
                                }
                            }
                            if (!flg) {
                                sb.append(value.charAt(index));
                            }
                        }
                    }
                    return sb.toString();
                };
                StiPdfExportService.convertToEscapeSequencePlusTabs = function (value) {
                    var escapeChars = [40, 41, 92, 13, 10, 9, 8, 12];
                    var replaceChars = "()\\rntbf";
                    var flg;
                    var sb;
                    if (value == null) {
                        return "";
                    }
                    else {
                        sb = new StringBuilder();
                        for (var index = 0; index < value.length; index++) {
                            flg = false;
                            for (var index2 = 0; index2 < escapeChars.length; index2++) {
                                if (value.charCodeAt(index) == escapeChars[index2]) {
                                    sb.append("\\" + replaceChars[index2]);
                                    flg = true;
                                    break;
                                }
                            }
                            if (!flg) {
                                sb.append(value.charAt(index));
                            }
                        }
                    }
                    return sb.toString();
                };
                StiPdfExportService.prototype.setStrokeColor = function (tempColor) {
                    var st = this.colorHash1.get(tempColor);
                    if (st == null) {
                        st = StiString.format("{0} {1} {2} RG", this.colorTable[tempColor.r], this.colorTable[tempColor.g], this.colorTable[tempColor.b]);
                        this.colorHash1.set(tempColor, st);
                    }
                    this.pageStream.writeLine(st);
                    var alpha = tempColor.a;
                    if ((alpha != this.lastColorStrokeA) && (StiOptions.Export.Pdf.allowExtGState && !this.usePdfA)) {
                        this.pageStream.writeLine(this.gsTable[alpha][0]);
                        this.lastColorStrokeA = alpha;
                        this.alphaTable[alpha] = true;
                    }
                };
                StiPdfExportService.prototype.setNonStrokeColor = function (tempColor) {
                    var st = this.colorHash2.get(tempColor);
                    if (st == null) {
                        st = StiString.format("{0} {1} {2} rg", this.colorTable[tempColor.r], this.colorTable[tempColor.g], this.colorTable[tempColor.b]);
                        this.colorHash2.set(tempColor, st);
                    }
                    this.pageStream.writeLine(st);
                    var alpha = tempColor.a;
                    if ((alpha != this.lastColorNonStrokeA) && (StiOptions.Export.Pdf.allowExtGState && !this.usePdfA)) {
                        this.pageStream.writeLine(this.gsTable[alpha][1]);
                        this.lastColorNonStrokeA = alpha;
                        this.alphaTable[alpha] = true;
                    }
                };
                Object.defineProperty(StiPdfExportService.prototype, "gsTable", {
                    get: function () {
                        if (this._gsTable == null) {
                            this._gsTable = Array.create(String, 256, 2);
                            for (var index = 0; index < 256; index++) {
                                this._gsTable[index][0] = StiString.format("/GS{0:X2}S gs", index);
                                this._gsTable[index][1] = StiString.format("/GS{0:X2}N gs", index);
                            }
                        }
                        return this._gsTable;
                    },
                    enumerable: true,
                    configurable: true
                });
                StiPdfExportService.prototype.pushColorToStack = function () {
                    this.colorStack.push(this.lastColorStrokeA);
                    this.colorStack.push(this.lastColorNonStrokeA);
                };
                StiPdfExportService.prototype.popColorFromStack = function () {
                    this.lastColorNonStrokeA = this.colorStack.pop();
                    this.lastColorStrokeA = this.colorStack.pop();
                };
                // Store encoded data
                StiPdfExportService.prototype.storeStringLine = function (noCryptString, cryptString, escaping) {
                    if (escaping === void 0) { escaping = false; }
                    var tempSt = noCryptString + this.convertToHexString(cryptString, escaping);
                    this.storeString(tempSt);
                    this.sw.writeLine();
                };
                StiPdfExportService.prototype.storeString = function (st) {
                    this.sw.writeString(st, false);
                };
                StiPdfExportService.prototype.convertToHexString = function (inString, escaping) {
                    var outString = new StringBuilder();
                    if (!StiString.isNullOrEmpty(inString)) {
                        var needHex = false;
                        for (var tempIndex = 0; tempIndex < inString.length; tempIndex++) {
                            if (inString.charCodeAt(tempIndex) > 127) {
                                needHex = true;
                            }
                        }
                        if (!this.encrypted) {
                            if (needHex == true) {
                                outString.append("<FEFF");
                                for (var index = 0; index < inString.length; index++) {
                                    outString.appendFormat("{0:X4}", inString.charCodeAt(index));
                                }
                                outString.append(">");
                            }
                            else {
                                if (escaping) {
                                    outString.append("(" + StiPdfExportService.convertToEscapeSequencePlusTabs(inString) + ")");
                                }
                                else {
                                    outString.append("(" + inString + ")");
                                }
                            }
                        }
                        else {
                            var forCrypt = null;
                            if (needHex == true) {
                                forCrypt = []; // new byte[(inString.Length + 1) * 2];
                                for (var index = 0; index < inString.length; index++) {
                                    var charValue = inString.charCodeAt(index);
                                    forCrypt[2 + index * 2 + 0] = (charValue >> 8) & 0xff;
                                    forCrypt[2 + index * 2 + 1] = (charValue) & 0xff;
                                }
                                forCrypt[0] = 0xFE;
                                forCrypt[1] = 0xFF;
                            }
                            else {
                                forCrypt = []; // new byte[inString.Length];
                                for (var index = 0; index < inString.length; index++) {
                                    forCrypt[index] = inString.charCodeAt(index);
                                }
                            }
                            var encryptedData = this.pdfSecurity.encryptData(forCrypt, this.currentObjectNumber, this.currentGenerationNumber);
                            var tempSB = "";
                            for (var index = 0; index < encryptedData.length; index++) {
                                tempSB += String.fromCharCode(encryptedData[index]);
                            }
                            outString.append("(" + StiPdfExportService.convertToEscapeSequencePlusTabs(tempSB) + ")");
                        }
                    }
                    else {
                        if (this.encrypted) {
                            var encryptedData = this.pdfSecurity.encryptData([], this.currentObjectNumber, this.currentGenerationNumber);
                            var tempSB = "";
                            for (var index = 0; index < encryptedData.length; index++) {
                                tempSB += String.fromCharCode(encryptedData[index]);
                            }
                            outString.append("(" + StiPdfExportService.convertToEscapeSequencePlusTabs(tempSB) + ")");
                        }
                        else {
                            outString.append("()");
                        }
                    }
                    return outString.toString();
                };
                StiPdfExportService.prototype.storeMemoryStream2 = function (mem, dictionaryString) {
                    if (this.encrypted) {
                        var encryptedData = this.pdfSecurity.encryptData(mem.toArray(), this.currentObjectNumber, this.currentGenerationNumber);
                        this.sw.writeLine(StiString.format(dictionaryString, encryptedData.length));
                        this.sw.writeLine(">>");
                        this.sw.writeLine("stream");
                        this.sw.write(encryptedData, 0, encryptedData.length);
                    }
                    else {
                        this.sw.writeLine(StiString.format(dictionaryString, mem.length));
                        this.sw.writeLine(">>");
                        this.sw.writeLine("stream");
                        mem.writeTo(this.sw);
                    }
                    mem.close();
                };
                StiPdfExportService.prototype.storeMemoryStream3 = function (data, dictionaryString) {
                    var memst = new MemoryStream();
                    for (var tempIndex = 0; tempIndex < data.length; tempIndex++) {
                        memst.writeByte(data[tempIndex]);
                    }
                    this.storeMemoryStream2(memst, dictionaryString);
                    memst.close();
                };
                StiPdfExportService.prototype.storeMemoryStream4 = function (data, dictionaryString) {
                    var memst = new MemoryStream();
                    for (var tempIndex = 0; tempIndex < data.length; tempIndex++) {
                        memst.writeByte(data[tempIndex]);
                    }
                    this.storeMemoryStream2(memst, dictionaryString);
                    memst.close();
                };
                //#endregion
                StiPdfExportService.prototype.renderStartDoc = function (report, pages) {
                    // header
                    this.sw.writeLine(this.keyLength == Export.StiPdfEncryptionKeyLength.Bit256_r5 || this.keyLength == Export.StiPdfEncryptionKeyLength.Bit256_r6 ? "%PDF-1.7" : "%PDF-1.4");
                    this.sw.write([37, 226, 227, 207, 211], 0, 5);
                    this.sw.writeLine();
                    // Catalog
                    this.addXref(1);
                    this.sw.writeLine("1 0 obj");
                    this.sw.writeLine("<<");
                    if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit256_r5)
                        this.sw.writeLine("/Extensions<</ADBE<</BaseVersion/1.7/ExtensionLevel 3>>>>");
                    if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit256_r6)
                        this.sw.writeLine("/Extensions<</ADBE<</BaseVersion/1.7/ExtensionLevel 8>>>>");
                    this.sw.writeLine("/Type /Catalog");
                    this.sw.writeLine("/Pages {0} 0 R", this.info.pages.ref);
                    this.sw.writeLine("/MarkInfo<</Marked true>>");
                    this.sw.writeLine("/Metadata {0} 0 R", this.info.metadata.ref);
                    this.sw.writeLine("/OutputIntents {0} 0 R", this.info.outputIntents.ref);
                    this.sw.writeLine("/StructTreeRoot {0} 0 R", this.info.structTreeRoot.ref);
                    if (this.haveBookmarks) {
                        this.sw.writeLine("/Outlines {0} 0 R", this.info.outlines.ref);
                        this.sw.writeLine("/PageMode /UseOutlines");
                    }
                    else {
                        this.sw.writeLine("/PageMode /UseNone");
                    }
                    if (!this.printScaling) {
                        this.sw.writeLine("/ViewerPreferences");
                        this.sw.writeLine("<<");
                        this.sw.writeLine("/PrintScaling /None");
                        this.sw.writeLine(">>");
                    }
                    if (this.haveAnnots || this.haveDigitalSignature) {
                        this.sw.writeLine("/AcroForm {0} 0 R", this.info.acroForm.ref);
                    }
                    if (this.autoPrint != Export.StiPdfAutoPrintMode.None) {
                        this.sw.writeLine("/Names <</JavaScript {0} 0 R>>", this.info.embeddedJS.ref);
                    }
                    if (!this.usePdfA) {
                        this.sw.writeLine("/OCProperties << /OCGs [{0} 0 R] /D << /ON [{0} 0 R] /AS [<</Event /Print /OCGs [{0} 0 R] /Category [/Print]>>] >> >>", this.info.optionalContentGroup.ref);
                    }
                    this.sw.writeLine(">>");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                    // Info
                    this.addXref(2);
                    this.sw.writeLine("2 0 obj");
                    this.sw.writeLine("<<");
                    this.storeStringLine("/Producer ", this.producerName, true);
                    this.storeStringLine("/Creator ", this.creatorName, true);
                    if (!StiString.isNullOrEmpty(report.reportAuthor)) {
                        this.storeStringLine("/Author ", report.reportAuthor, true);
                    }
                    if (!StiString.isNullOrEmpty(report.reportAlias)) {
                        this.storeStringLine("/Subject ", report.reportAlias, true);
                    }
                    if (!StiString.isNullOrEmpty(report.reportName)) {
                        this.storeStringLine("/Title ", report.reportName, true);
                    }
                    if (!StiString.isNullOrEmpty(this.keywords)) {
                        this.storeStringLine("/Keywords ", this.keywords, true);
                    }
                    this.storeStringLine("/CreationDate ", "D:" + this.currentDateTime);
                    this.storeStringLine("/ModDate ", "D:" + this.currentDateTime);
                    // foreach(StiMetaTag meta in report.MetaTags)
                    // {
                    //    if (meta.Name.sti.startsWith("pdf:")) {
                    //        this.storeStringLine(string.Format("/{0} ", StiNameValidator.CorrectName(meta.Name.Substr(4), false)), meta.Tag);
                    //    }
                    // }
                    this.sw.writeLine(">>");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                    // Colorspace
                    this.addXref(3);
                    this.sw.writeLine("3 0 obj");
                    this.sw.writeLine("<<");
                    this.sw.writeLine("/Cs1 [/Pattern /DeviceRGB]");
                    this.sw.writeLine(">>");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                    // make resources list
                    var resourcesList = [];
                    resourcesList.add("/Resources");
                    resourcesList.add("<<");
                    resourcesList.add("/ProcSet [/PDF /Text /ImageC]");
                    resourcesList.add("/Font");
                    resourcesList.add("<<");
                    for (var index = 0; index < this.fontsCounter; index++) {
                        resourcesList.add(StiString.format("/F{0} {1} 0 R", index, this.info.fontList[index].ref));
                    }
                    resourcesList.add(">>");
                    if (this.imageCache.imageStore.length > 0) {
                        resourcesList.add("/XObject");
                        resourcesList.add("<<");
                        for (var index = 0; index < this.imageCache.imageStore.length; index++) {
                            resourcesList.add(StiString.format("/Image{0} {1} 0 R", index, this.info.xObjectList[index].ref));
                        }
                        resourcesList.add(">>");
                    }
                    resourcesList.add("/Pattern");
                    resourcesList.add("<<");
                    resourcesList.add(StiString.format("/P1 {0} 0 R", this.info.patterns.first.ref));
                    for (var indexPattern = 0; indexPattern < this.hatchArray.length; indexPattern++) {
                        resourcesList.add(StiString.format("/PH{0} {1} 0 R", 1 + indexPattern, this.info.patterns.hatchItems[indexPattern].ref));
                    }
                    for (var indexPattern = 0; indexPattern < this.shadingArray.length; indexPattern++) {
                        resourcesList.add(StiString.format("/P{0} {1} 0 R", 2 + indexPattern, this.info.patterns.shadingItems[indexPattern].ref));
                    }
                    resourcesList.add(">>");
                    resourcesList.add("/ColorSpace 3 0 R");
                    if (StiOptions.Export.Pdf.allowExtGState && !this.usePdfA) {
                        resourcesList.add(StiString.format("/ExtGState {0} 0 R", this.info.extGState.ref));
                    }
                    if (!this.usePdfA) {
                        resourcesList.add(StiString.format("/Properties << /oc1 {0} 0 R >>", this.info.optionalContentGroup.ref));
                    }
                    resourcesList.add(">>");
                    // Pages
                    this.addXref(this.info.pages.ref);
                    this.sw.writeLine("{0} 0 obj", this.info.pages.ref);
                    this.sw.writeLine("<<");
                    this.sw.writeLine("/Type /Pages");
                    this.sw.writeLine("/Kids [");
                    for (var index = 0; index < pages.count; index++) {
                        this.sw.writeLine("{0} 0 R", this.info.pageList[index].ref);
                    }
                    this.sw.writeLine("]");
                    this.sw.writeLine("/Count {0}", pages.count);
                    if (StiOptions.Export.Pdf.allowInheritedPageResources) {
                        for (var indexResourcesList = 0; indexResourcesList < resourcesList.length; indexResourcesList++) {
                            this.sw.writeLine(resourcesList[indexResourcesList]);
                        }
                    }
                    this.sw.writeLine(">>");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                    // StructTreeRoot
                    this.addXref(5);
                    this.sw.writeLine("5 0 obj");
                    this.sw.writeLine("<<");
                    this.sw.writeLine("/Type /StructTreeRoot");
                    this.sw.writeLine(">>");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                    // OptionalContentGroup
                    this.addXref(6);
                    this.sw.writeLine("6 0 obj");
                    this.sw.writeLine("<<");
                    this.sw.writeLine("/Type /OCG");
                    this.sw.writeLine("/Name (Printable off)");
                    this.sw.writeLine("/Usage <<");
                    this.sw.writeLine("/Print << /PrintState /OFF >>");
                    this.sw.writeLine("/View << /ViewState /ON >>");
                    this.sw.writeLine(">>");
                    this.sw.writeLine(">>");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                    // Page
                    for (var index = 0; index < pages.count; index++) {
                        this.addXref(this.info.pageList[index].ref);
                        this.sw.writeLine("{0} 0 obj", this.info.pageList[index].ref);
                        this.sw.writeLine("<<");
                        this.sw.writeLine("/Type /Page");
                        this.sw.writeLine("/Parent 4 0 R");
                        var pageHeight = this.hiToTwips * report.unit.convertToHInches(pages.getByIndex(index).pageHeight * pages.getByIndex(index).segmentPerHeight);
                        var pageWidth = this.hiToTwips * report.unit.convertToHInches(pages.getByIndex(index).pageWidth * pages.getByIndex(index).segmentPerWidth);
                        // Adobe Acrobat limitation of page size: maximum 200" * 200"
                        if (pageHeight > 14400) {
                            pageHeight = 14400;
                        }
                        if (pageWidth > 14400) {
                            pageWidth = 14400;
                        }
                        this.sw.writeLine("/MediaBox [ 0 0 {0} {1} ]", this.convertToString(pageWidth), this.convertToString(pageHeight));
                        if (!StiOptions.Export.Pdf.allowInheritedPageResources) {
                            for (var indexResourcesList = 0; indexResourcesList < resourcesList.length; indexResourcesList++) {
                                this.sw.writeLine(resourcesList[indexResourcesList]);
                            }
                        }
                        this.sw.writeLine("/Contents {0} 0 R", this.info.pageList[index].content.ref);
                        if (!this.usePdfA) {
                            this.sw.writeLine("/Group");
                            this.sw.writeLine("<<");
                            this.sw.writeLine("/Type /Group");
                            this.sw.writeLine("/S /Transparency");
                            this.sw.writeLine("/CS /DeviceRGB");
                            this.sw.writeLine(">>");
                        }
                        if (this.haveLinks || this.haveAnnots || this.haveDigitalSignature || this.haveTooltips) {
                            this.sw.writeLine("/Annots [");
                            // if (haveLinks) {
                            //    for (int tempIndex = 0; tempIndex < linksCounter; tempIndex++)
                            //    {
                            //        StiLinkObject stl = (StiLinkObject)linksArray[tempIndex];
                            //        if (stl.Page == index) {
                            //            this.sw.writeLine("{0} 0 R ", this.info.LinkList[tempIndex].ref);
                            //        }
                            //    }
                            // }
                            if (this.haveAnnots) {
                                for (var tempIndex = 0; tempIndex < this.annotsCounter; tempIndex++) {
                                    var seo = this.annotsArray[tempIndex];
                                    if (seo.Page == index) {
                                        this.sw.writeLine("{0} 0 R ", this.info.acroForm.annots[tempIndex].ref);
                                    }
                                }
                                for (var tempIndex = 0; tempIndex < this.annots2Counter; tempIndex++) {
                                    var seo = this.annots2Array[tempIndex];
                                    if (seo.Page == index) {
                                        for (var indexState = 0; indexState < this.info.acroForm.checkBoxes[tempIndex].items.length; indexState++) {
                                            this.sw.writeLine("{0} 0 R ", this.info.acroForm.checkBoxes[tempIndex].items[indexState].ref);
                                        }
                                    }
                                }
                                // for (int tempIndex = 0; tempIndex < unsignedSignaturesCounter; tempIndex++)
                                // {
                                //    StiEditableObject seo = (StiEditableObject)unsignedSignaturesArray[tempIndex];
                                //    if (seo.Page == index) {
                                //        this.sw.writeLine("{0} 0 R ", this.info.AcroForm.UnsignedSignatures[tempIndex].ref);
                                //    }
                                // }
                            }
                            // if ((haveDigitalSignature) && (index == signaturePageNumber)) {
                            //    this.sw.writeLine("{0} 0 R ", this.info.AcroForm.Signatures[0].ref);
                            // }
                            // if (haveTooltips) {
                            //    for (int tempIndex = 0; tempIndex < tooltipsCounter; tempIndex++)
                            //    {
                            //        StiLinkObject stl = (StiLinkObject)tooltipsArray[tempIndex];
                            //        if (stl.Page == index) {
                            //            this.sw.writeLine("{0} 0 R ", this.info.AcroForm.Tooltips[tempIndex].ref);
                            //        }
                            //    }
                            // }
                            this.sw.writeLine("]");
                        }
                        this.sw.writeLine(">>");
                        this.sw.writeLine("endobj");
                        this.sw.writeLine("");
                    }
                };
                StiPdfExportService.prototype.renderEndDoc = function () {
                    var offs = this.sw.position;
                    this.sw.writeLine("xref");
                    this.sw.writeLine("0 {0}", this.xref.length + 1);
                    this.sw.writeLine("0000000000 65535 f");
                    for (var index = 0; index < this.xref.length; index++) {
                        this.sw.writeLine(this.xref[index + 1]);
                    }
                    this.sw.writeLine("trailer");
                    this.sw.writeLine("<<");
                    this.sw.writeLine("/Size {0}", this.xref.length + 1);
                    this.sw.writeLine("/Root 1 0 R");
                    this.sw.writeLine("/Info 2 0 R");
                    if (this.encrypted) {
                        this.sw.writeLine("/Encrypt {0} 0 R", this.info.encode.ref);
                    }
                    this.sw.writeLine("/ID[<{0}><{0}>]", this.IDValueString);
                    this.sw.writeLine(">>");
                    this.sw.writeLine("%" + Export.StiExportUtils.getReportVersion());
                    this.sw.writeLine("%" + Stimulsoft.StiVersion.platform());
                    this.sw.writeLine("startxref");
                    this.sw.writeLine("{0}", offs);
                    this.sw.writeLine("%%EOF");
                };
                StiPdfExportService.prototype.renderPageHeader = function (pageNumber) {
                    this.addXref(this.info.pageList[pageNumber].content.ref);
                    this.sw.writeLine("{0} 0 obj", this.info.pageList[pageNumber].content.ref);
                    this.sw.writeLine("<<");
                    this.pageStream = new MemoryStream();
                    this.pageStream.writeLine("2 J");
                };
                StiPdfExportService.prototype.renderPageFooter = function (pageH, pageW) {
                    // *#if Demo
                    if (!Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnJS() && !Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnDbsJS() &&
                        !(Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnBI() && Stimulsoft.StiVersion.isStandaloneVersion())) {
                        var tempX = pageW / 596 * 1.4;
                        var tempY = pageH / 840 * 1.4;
                        if (tempX > tempY)
                            tempX = tempY;
                        else
                            tempY = tempX;
                        this.pageStream.writeLine("q");
                        this.pushColorToStack();
                        this.pageStream.writeLine("1 J 1 j 20 w");
                        this.setStrokeColor(Color.fromArgb(64, 100, 100, 100));
                        this.pageStream.writeLine("{0} 0 0 {1} {2} {3} cm 0.707 0.707 -0.707 0.707 0 0 cm 1 0 0 1 -155 -50 cm", this.convertToString(tempX), this.convertToString(tempY), this.convertToString(pageW / 2), this.convertToString(pageH / 2));
                        this.pageStream.writeLine("40 0 m 40 100 l 0 100 m 80 100 l S");
                        this.pageStream.writeLine("100 0 m 100 70 l 100 45 m 120 65 l 130 72 l 140 68 l S");
                        this.pageStream.writeLine("170 0 m 170 70 l 169 100 m 171 100 l S");
                        this.pageStream.writeLine("215 60 m 222 69 l 232 71 l 255 70 l 265 60 l 265 5 l 270 0 l 265 44 m 220 31 l 212 20 l 212 10 l 225 0 l 235 0 l 250 5 l 265 18 l S");
                        this.pageStream.writeLine("310 0 m 310 100 l S");
                        // this.pageStream.writeLine("0 0 m 0 30 l 10 30 l 20 20 l 20 10 l 10 0 l s");
                        // this.pageStream.writeLine("50 0 m 30 0 l 30 30 l 50 30 l 30 20 m 40 20 l S");
                        // this.pageStream.writeLine("60 0 m 60 30 l 70 20 l 80 30 l 80 0 l S");
                        // this.pageStream.writeLine("90 5 m 90 25 l 95 30 l 105 30 l 110 25 l 110 5 l 105 0 l 95 0 l s");
                        this.pageStream.writeLine("Q");
                        this.popColorFromStack();
                    }
                    // #endif Demo*/
                    if (this.pageStream.position < this.pageStream.length) {
                        this.pageStream.setLength(this.pageStream.position);
                    }
                    if (this.compressed == true) {
                        var bytedata = this.pageStream.toArray();
                        var tmpStream = Export.StiExportUtils.makePdfDeflateStream(bytedata);
                        this.storeMemoryStream2(tmpStream, "/Filter [/FlateDecode] /Length {0}");
                    }
                    else {
                        this.storeMemoryStream2(this.pageStream, "/Filter [] /Length {0}");
                    }
                    this.sw.writeLine();
                    this.pageStream.close();
                    this.sw.writeLine("endstream");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                };
                StiPdfExportService.prototype.renderFontTable = function () {
                    // write fonts table
                    for (var index = 0; index < this.fontsCounter; index++) {
                        var tempSb = new StringBuilder();
                        this.pdfFont.currentFont = index;
                        var tempInfo = this.pdfFont.fontList[index];
                        var fontName = tempInfo.Name;
                        if (StiOptions.Export.Pdf.useAlternativeFontNames && StiOptions.Export.Pdf.alternativeFontNames.containsKey(fontName)) {
                            fontName = StiOptions.Export.Pdf.alternativeFontNames.get(fontName);
                        }
                        if (this.useUnicodeMode) {
                            //#region main font info for Unicode
                            tempSb = new StringBuilder(fontName.sti.replaceAll(" ", "#20"));
                            if (tempInfo.Bold || tempInfo.Italic) {
                                tempSb.append(",");
                                if (tempInfo.Bold)
                                    tempSb.append("Bold");
                                if (tempInfo.Italic)
                                    tempSb.append("Italic");
                            }
                            if (this.embeddedFonts) {
                                tempSb.insert(0, StiString.format("SR{0}{1}{2}{3}+", String.fromCharCode(Math.random() * 24 + 65), String.fromCharCode(Math.random() * 24 + 65), String.fromCharCode(Math.random() * 24 + 65), String.fromCharCode(Math.random() * 24 + 65)));
                            }
                            this.addXref(this.info.fontList[index].ref);
                            this.sw.writeLine("{0} 0 obj", this.info.fontList[index].ref);
                            this.sw.writeLine("<<");
                            this.sw.writeLine("/Type /Font");
                            this.sw.writeLine("/Subtype /Type0");
                            this.sw.writeLine("/BaseFont /{0}", tempSb);
                            this.sw.writeLine("/DescendantFonts [{0} 0 R]", this.info.fontList[index].descendantFont.ref);
                            this.sw.writeLine("/Encoding /Identity-H");
                            this.sw.writeLine("/ToUnicode {0} 0 R", this.info.fontList[index].toUnicode.ref);
                            this.sw.writeLine("/Name /F{0}", index);
                            this.sw.writeLine(">>");
                            this.sw.writeLine("endobj");
                            this.sw.writeLine("");
                            this.addXref(this.info.fontList[index].descendantFont.ref);
                            this.sw.writeLine("{0} 0 obj", this.info.fontList[index].descendantFont.ref);
                            this.sw.writeLine("<<");
                            this.sw.writeLine("/Type /Font");
                            this.sw.writeLine("/Subtype /CIDFontType2");
                            this.sw.writeLine("/BaseFont /{0}", tempSb);
                            this.sw.writeLine("/CIDSystemInfo");
                            this.sw.writeLine("<<");
                            this.storeStringLine("/Registry", "Adobe");
                            this.storeStringLine("/Ordering", "Identity");
                            this.sw.writeLine("/Supplement 0");
                            this.sw.writeLine(">>");
                            this.sw.writeLine("/FontDescriptor {0} 0 R", this.info.fontList[index].fontDescriptor.ref);
                            if (this.usePdfA) {
                                this.sw.writeLine("/CIDToGIDMap /Identity");
                            }
                            this.sw.writeLine("/W [0 [1000]");
                            var pdfGlyphList = this.pdfFont.GlyphList;
                            var pdfGlyphListLength = pdfGlyphList.length;
                            // make arrays
                            var glyphList = Array.create(Number, pdfGlyphListLength);
                            var glyphListBack = Array.create(Number, pdfGlyphListLength);
                            for (var glyphIndex = 32; glyphIndex < pdfGlyphListLength; glyphIndex++) {
                                glyphList[glyphIndex] = pdfGlyphList[glyphIndex];
                                glyphListBack[glyphIndex] = glyphIndex;
                            }
                            // sort arrays
                            for (var index1 = 32; index1 < glyphList.length - 1; index1++) {
                                for (var index2 = index1 + 1; index2 < glyphList.length; index2++) {
                                    if (glyphList[index1] > glyphList[index2]) {
                                        var tempGlyph = glyphList[index1];
                                        glyphList[index1] = glyphList[index2];
                                        glyphList[index2] = tempGlyph;
                                        var tempGlyphBack = glyphListBack[index1];
                                        glyphListBack[index1] = glyphListBack[index2];
                                        glyphListBack[index2] = tempGlyphBack;
                                    }
                                }
                            }
                            var sb = new StringBuilder();
                            var mapIndex = 32;
                            while (mapIndex < this.pdfFont.MappedSymbolsCount) {
                                sb.append(glyphList[mapIndex].toString() + " [");
                                sb.append(this.pdfFont.Widths[glyphListBack[mapIndex] - 32].toString());
                                mapIndex++;
                                while ((mapIndex < this.pdfFont.MappedSymbolsCount) &&
                                    (glyphList[mapIndex] - 1 == glyphList[mapIndex - 1])) {
                                    sb.append(" " + this.pdfFont.Widths[glyphListBack[mapIndex] - 32].toString());
                                    mapIndex++;
                                }
                                // some symbols may be translated to one glyph
                                while ((mapIndex < this.pdfFont.MappedSymbolsCount) && (glyphList[mapIndex] == glyphList[mapIndex - 1])) {
                                    mapIndex++;
                                }
                                sb.append("]");
                                this.sw.writeLine("{0}", sb);
                                sb = new StringBuilder();
                            }
                            if (this.pdfFont.GlyphWidths != null && this.pdfFont.GlyphWidths[0xFFFF] != 0) {
                                // for (int indexGlyph = 0; indexGlyph < 65535; indexGlyph++)
                                // {
                                //    if ((pdfFont.GlyphWidths[indexGlyph] > 0) && (pdfFont.GlyphBackList[indexGlyph] == 0)) {
                                //        this.sw.writeLine(string.Format("{0} [{1}]", indexGlyph, this.pdfFont.GlyphWidths[indexGlyph]));
                                //    }
                                // }
                            }
                            this.sw.writeLine("]");
                            this.sw.writeLine(">>");
                            this.sw.writeLine("endobj");
                            this.sw.writeLine("");
                            //#region ToUnicode
                            this.addXref(this.info.fontList[index].toUnicode.ref);
                            var cmapFontName = "SR+F" + index.toString();
                            this.sw.writeLine("{0} 0 obj", this.info.fontList[index].toUnicode.ref);
                            this.sw.writeLine("<<");
                            //#region prepare memory stream and buffer
                            var swmem = new MemoryStream();
                            swmem.writeLine("/CIDInit /ProcSet findresource begin");
                            swmem.writeLine("12 dict begin");
                            swmem.writeLine("begincmap");
                            swmem.writeLine("/CIDSystemInfo");
                            swmem.writeLine("<<");
                            swmem.writeLine("/Registry (Adobe)");
                            swmem.writeLine("/Ordering ({0})", cmapFontName);
                            swmem.writeLine("/Supplement 0");
                            swmem.writeLine(">> def");
                            swmem.writeLine("/CMapName /{0} def", cmapFontName);
                            swmem.writeLine("/CMapType 2 def");
                            swmem.writeLine("1 begincodespacerange");
                            swmem.writeLine("<0000> <FFFF>");
                            swmem.writeLine("endcodespacerange");
                            var countBfChar = this.pdfFont.MappedSymbolsCount - 32;
                            var offsetBfChar = 32;
                            while (countBfChar > 0) {
                                var count = countBfChar;
                                if (count > 100)
                                    count = 100;
                                swmem.writeLine("{0} beginbfchar", count);
                                for (var indexUni = 0; indexUni < count; indexUni++) {
                                    swmem.writeLine("<{0:X4}> <{1:X4}>", this.pdfFont.GlyphList[offsetBfChar], this.pdfFont.UnicodeMapBack[offsetBfChar]);
                                    offsetBfChar++;
                                }
                                swmem.writeLine("endbfchar");
                                countBfChar -= count;
                            }
                            swmem.writeLine("endcmap");
                            swmem.writeLine("CMapName currentdict /CMap defineresource pop");
                            swmem.writeLine("end");
                            swmem.writeLine("end");
                            swmem.flush();
                            var buff_1 = swmem.toArray();
                            swmem.close();
                            //#endregion
                            if (this.compressed == true) {
                                var tmpStream = Export.StiExportUtils.makePdfDeflateStream(buff_1);
                                this.storeMemoryStream2(tmpStream, "/Length {0} /Filter [/FlateDecode] /Length1 " + buff_1.length.toString());
                            }
                            else {
                                this.storeMemoryStream4(buff_1, "/Length {0} /Filter [] /Length1 {0}");
                            }
                            this.sw.writeLine("");
                            this.sw.writeLine("endstream");
                            this.sw.writeLine("endobj");
                            this.sw.writeLine("");
                            //#endregion
                            //#region CIDSet
                            this.addXref(this.info.fontList[index].cIDSet.ref);
                            this.sw.writeLine("{0} 0 obj", this.info.fontList[index].cIDSet.ref);
                            this.sw.writeLine("<<");
                            //#region prepare buffer
                            var bits = Array.create(Boolean, 65536 + 32);
                            var maxIndex = 0;
                            for (var indexGlyph = 0; indexGlyph < this.pdfFont.GlyphList.length; indexGlyph++) {
                                var glyph = this.pdfFont.GlyphList[indexGlyph];
                                if (glyph != 65535) {
                                    bits[glyph] = true;
                                    if (glyph > maxIndex)
                                        maxIndex = glyph;
                                }
                            }
                            if (this.pdfFont.GlyphWidths != null && this.pdfFont.GlyphWidths[0xFFFF] != 0) {
                                for (var indexGlyph = 0; indexGlyph < 65535; indexGlyph++) {
                                    if ((this.pdfFont.GlyphWidths[indexGlyph] > 0) && (this.pdfFont.GlyphBackList[indexGlyph] == 0)) {
                                        bits[indexGlyph] = true;
                                        if (indexGlyph > maxIndex)
                                            maxIndex = indexGlyph;
                                    }
                                }
                            }
                            var bytesCount = Math.trunc(maxIndex / 8) + 1;
                            var buff2 = Array.create(Number, bytesCount + 1);
                            var pos = 0;
                            while (pos < bytesCount) {
                                var offset = pos * 8;
                                var val = 0;
                                if (bits[offset])
                                    val |= 0x80;
                                if (bits[offset + 1])
                                    val |= 0x40;
                                if (bits[offset + 2])
                                    val |= 0x20;
                                if (bits[offset + 3])
                                    val |= 0x10;
                                if (bits[offset + 4])
                                    val |= 0x08;
                                if (bits[offset + 5])
                                    val |= 0x04;
                                if (bits[offset + 6])
                                    val |= 0x02;
                                if (bits[offset + 7])
                                    val |= 0x01;
                                buff2[pos] = val;
                                pos++;
                            }
                            //#endregion
                            if (this.compressed == true) {
                                var tmpStream = Export.StiExportUtils.makePdfDeflateStream(buff2);
                                this.storeMemoryStream2(tmpStream, "/Length {0} /Filter [/FlateDecode] /Length1 " + buff2.length.toString());
                            }
                            else {
                                this.storeMemoryStream4(buff2, "/Length {0} /Filter [] /Length1 " + buff2.length.toString());
                            }
                            this.sw.writeLine("");
                            this.sw.writeLine("endstream");
                            this.sw.writeLine("endobj");
                            this.sw.writeLine("");
                            //#endregion
                        }
                        else {
                            // main font info
                            this.addXref(this.info.fontList[index].ref);
                            this.sw.writeLine("{0} 0 obj", this.info.fontList[index].ref);
                            this.sw.writeLine("<<");
                            this.sw.writeLine("/Type /Font");
                            if (this.standardPdfFonts == true) {
                                this.sw.writeLine("/Subtype /Type1");
                                this.sw.writeLine("/BaseFont /{0}", tempInfo.PdfName);
                            }
                            else {
                                this.sw.writeLine("/Subtype /TrueType");
                                tempSb = new StringBuilder(this.stringReplace(fontName, " ", "#20"));
                                if ((tempInfo.Bold == true) || (tempInfo.Italic == true)) {
                                    tempSb.append(",");
                                    if (tempInfo.Bold == true)
                                        tempSb.append("Bold");
                                    if (tempInfo.Italic == true)
                                        tempSb.append("Italic");
                                }
                                this.sw.writeLine("/BaseFont /{0}", tempSb);
                                this.sw.writeLine("/FontDescriptor {0} 0 R", this.info.fontList[index].fontDescriptor.ref);
                            }
                            this.sw.writeLine("/Encoding {0} 0 R", this.info.fontList[index].encoding.ref);
                            // make string "Widths"
                            var sbWidths = new StringBuilder(" ");
                            for (var indexUni = 32; indexUni < this.pdfFont.MappedSymbolsCount; indexUni++) {
                                sbWidths.append(this.pdfFont.Widths[indexUni - 32].toString() + " ");
                            }
                            this.sw.writeLine("/FirstChar {0}", 32);
                            this.sw.writeLine("/LastChar {0}", this.pdfFont.MappedSymbolsCount - 1);
                            this.sw.writeLine("/Widths [{0}]", sbWidths);
                            this.sw.writeLine("/Name /F{0}", index);
                            this.sw.writeLine(">>");
                            this.sw.writeLine("endobj");
                            this.sw.writeLine("");
                            // Encoding
                            this.addXref(this.info.fontList[index].encoding.ref);
                            this.sw.writeLine("{0} 0 obj", this.info.fontList[index].encoding.ref);
                            this.sw.writeLine("<<");
                            this.sw.writeLine("/Type /Encoding");
                            this.sw.writeLine("/BaseEncoding /WinAnsiEncoding");
                            if (this.pdfFont.MappedSymbolsCount > this.pdfFont.firstMappedSymbol) {
                                // make string "Differences"
                                var sbDifferences = new StringBuilder(this.pdfFont.firstMappedSymbol.toString() + " ");
                                for (var indexUni = this.pdfFont.firstMappedSymbol; indexUni < this.pdfFont.MappedSymbolsCount; indexUni++) {
                                    sbDifferences.append("/" + this.pdfFont.CharPdfNames[indexUni]);
                                }
                                this.sw.writeLine("/Differences [{0}]", sbDifferences);
                            }
                            this.sw.writeLine(">>");
                            this.sw.writeLine("endobj");
                            this.sw.writeLine("");
                        }
                        // get font data buff
                        var buff = null;
                        if (this.embeddedFonts) {
                            var fontData = Stimulsoft.Base.StiFontCollection.getBinFont(tempInfo.Font.name, tempInfo.Font.style);
                            buff = fontData != null ? fontData.data : null;
                            if (buff != null && !buff.sti.is(Uint8Array))
                                buff = null;
                            if (buff == null) {
                                var isBold = (tempInfo.Font.style & FontStyle.Bold) > 0;
                                var isItalic = (tempInfo.Font.style & FontStyle.Italic) > 0;
                                if (isBold && isItalic) {
                                    fontData = Stimulsoft.Base.StiFontCollection.getBinFont(tempInfo.Font.name, FontStyle.Italic);
                                    if (fontData != null && fontData.data != null) {
                                        buff = fontData.data;
                                    }
                                    else {
                                        fontData = Stimulsoft.Base.StiFontCollection.getBinFont(tempInfo.Font.name, FontStyle.Bold);
                                        if (fontData != null && fontData.data != null) {
                                            buff = fontData.data;
                                        }
                                        else {
                                            fontData = Stimulsoft.Base.StiFontCollection.getBinFont(tempInfo.Font.name, FontStyle.Regular);
                                            if (fontData != null && fontData.data != null) {
                                                buff = fontData.data;
                                            }
                                        }
                                    }
                                }
                                else {
                                    if (isBold) {
                                        fontData = Stimulsoft.Base.StiFontCollection.getBinFont(tempInfo.Font.name, FontStyle.Regular);
                                        if (fontData != null && fontData.data != null) {
                                            buff = fontData.data;
                                        }
                                    }
                                    if (isItalic) {
                                        fontData = Stimulsoft.Base.StiFontCollection.getBinFont(tempInfo.Font.name, FontStyle.Regular);
                                        if (fontData != null && fontData.data != null) {
                                            buff = fontData.data;
                                        }
                                    }
                                }
                            }
                            if (buff == null) {
                                var resource = this.report.dictionary.resources.getByName(tempInfo.Font.name);
                                if (resource == null)
                                    resource = this.report.dictionary.resources.getByAlias(tempInfo.Font.name);
                                if (resource != null && resource.content != null && resource.content.length > 0) {
                                    buff = new Uint8Array(resource.content);
                                }
                            }
                        }
                        if (this.standardPdfFonts == false) {
                            // FontDescriptor
                            this.addXref(this.info.fontList[index].fontDescriptor.ref);
                            this.sw.writeLine("{0} 0 obj", this.info.fontList[index].fontDescriptor.ref);
                            this.sw.writeLine("<<");
                            this.sw.writeLine("/Type /FontDescriptor");
                            this.sw.writeLine("/FontName /{0}", tempSb);
                            this.sw.writeLine("/Flags 32");
                            this.sw.writeLine("/Ascent {0}", this.pdfFont.tmASC);
                            this.sw.writeLine("/CapHeight {0}", this.pdfFont.CH);
                            this.sw.writeLine("/Descent {0}", this.pdfFont.tmDESC);
                            this.sw.writeLine("/FontBBox [{0} {1} {2} {3}]", this.pdfFont.LLX, this.pdfFont.LLY, this.pdfFont.URX, this.pdfFont.URY);
                            this.sw.writeLine("/ItalicAngle {0}", this.pdfFont.ItalicAngle);
                            this.sw.writeLine("/StemV {0}", this.pdfFont.StemV);
                            if (this.embeddedFonts == true && buff != null) {
                                this.sw.writeLine("/FontFile2 {0} 0 R", this.info.fontList[tempInfo.ParentFontNumber == -1 ? index : tempInfo.ParentFontNumber].fontFile2.ref);
                            }
                            var needCIDSet = this.useUnicodeMode == true;
                            if (this.pdfComplianceMode == Export.StiPdfComplianceMode.A2 || this.pdfComplianceMode == Export.StiPdfComplianceMode.A3)
                                needCIDSet = false;
                            if (needCIDSet) {
                                this.sw.writeLine("/CIDSet {0} 0 R", this.info.fontList[index].cIDSet.ref);
                            }
                            this.sw.writeLine(">>");
                            this.sw.writeLine("endobj");
                            this.sw.writeLine("");
                        }
                        if (this.embeddedFonts) {
                            // embedded
                            if (buff != null && buff.length > 0 && tempInfo.ParentFontNumber == -1) {
                                if (this.reduceFontSize) {
                                    var buff2 = this.pdfFont.reduceFontSize(buff, tempInfo.Name, !this.fontGlyphsReduceNotNeed[index]);
                                    if (buff2 != null)
                                        buff = buff2;
                                }
                                this.addXref(this.info.fontList[index].fontFile2.ref);
                                this.sw.writeLine("{0} 0 obj", this.info.fontList[index].fontFile2.ref);
                                this.sw.writeLine("<<");
                                if (this.compressedFonts == true) {
                                    if (buff.sti.is(Uint8Array)) {
                                        var tmpStream = Export.StiExportUtils.makePdfDeflateStream(buff);
                                        this.storeMemoryStream2(tmpStream, "/Length {0} /Filter [/FlateDecode] /Length1 " + buff.length.toString());
                                    }
                                    if (buff.sti.is(MemoryStream)) {
                                        var tempBuf = buff.toArray();
                                        var tmpStream = Export.StiExportUtils.makePdfDeflateStream(tempBuf);
                                        this.storeMemoryStream2(tmpStream, "/Length {0} /Filter [/FlateDecode] /Length1 " + buff.length.toString());
                                    }
                                }
                                else {
                                    if (buff.sti.is(Uint8Array))
                                        this.storeMemoryStream3(buff, "/Length {0} /Filter [] /Length1 " + buff.length.toString());
                                    if (buff.sti.is(MemoryStream))
                                        this.storeMemoryStream2(buff, "/Length {0} /Filter [] /Length1 " + buff.length.toString());
                                }
                                this.sw.writeLine("");
                                this.sw.writeLine("endstream");
                                this.sw.writeLine("endobj");
                                this.sw.writeLine("");
                            }
                            else {
                                this.addXref(this.info.fontList[index].fontFile2.ref);
                                this.sw.writeLine("{0} 0 obj", this.info.fontList[index].fontFile2.ref);
                                this.sw.writeLine("<< >>");
                                this.sw.writeLine("endobj");
                                this.sw.writeLine("");
                            }
                        }
                    }
                };
                StiPdfExportService.prototype.renderImageTable = function () {
                    if (this.imageCache.imageStore.length > 0) {
                        for (var index = 0; index < this.imageCache.imageStore.length; index++) {
                            var pd = this.imageCacheIndexToList.get(index);
                            var bytes = this.imageCache.imagePackedStore[index];
                            var mask = this.imageCache.imageMaskStore[index];
                            var imageFormatCurrent = pd.ImageFormat;
                            this.addXref(this.info.xObjectList[index].ref);
                            this.sw.writeLine("{0} 0 obj", this.info.xObjectList[index].ref);
                            this.sw.writeLine("<<");
                            this.sw.writeLine("/Type /XObject");
                            this.sw.writeLine("/Subtype /Image");
                            this.sw.writeLine("/ColorSpace /{0}", imageFormatCurrent == Export.StiImageFormat.Monochrome ? "DeviceGray" : "DeviceRGB");
                            this.sw.writeLine("/Width {0}", pd.Width);
                            this.sw.writeLine("/Height {0}", pd.Height);
                            this.sw.writeLine("/BitsPerComponent {0}", imageFormatCurrent == Export.StiImageFormat.Monochrome ? "1" : "8");
                            if (this.imageInterpolationTable.containsKey(index)) {
                                this.sw.writeLine("/Interpolate true");
                            }
                            if (mask != null) {
                                this.sw.writeLine("/SMask {0} 0 R", this.info.xObjectList[index].mask.ref);
                            }
                            this.sw.writeLine("/Name /{0}", pd.Name);
                            var compressionType = "DCTDecode";
                            if (this.imageCompressionMethod == Export.StiPdfImageCompressionMethod.Flate)
                                compressionType = "FlateDecode";
                            if (bytes == null) {
                                bytes = [56, 48, 56, 48, 56, 48];
                                compressionType = "ASCIIHexDecode";
                            }
                            var stImage = "/Length {0} " + StiString.format("/Filter [/{0}]", compressionType);
                            var TmpStream = new MemoryStream();
                            TmpStream.write(bytes, 0, bytes.length);
                            this.storeMemoryStream2(TmpStream, stImage);
                            this.sw.writeLine("");
                            this.sw.writeLine("endstream");
                            this.sw.writeLine("endobj");
                            this.sw.writeLine("");
                            if (mask != null) {
                                this.addXref(this.info.xObjectList[index].mask.ref);
                                this.sw.writeLine("{0} 0 obj", this.info.xObjectList[index].mask.ref);
                                this.sw.writeLine("<<");
                                this.sw.writeLine("/Type /XObject");
                                this.sw.writeLine("/Subtype /Image");
                                this.sw.writeLine("/ColorSpace /DeviceGray");
                                this.sw.writeLine("/Matte [ 0 0 0 ]");
                                this.sw.writeLine("/Width {0}", pd.Width);
                                this.sw.writeLine("/Height {0}", pd.Height);
                                this.sw.writeLine("/BitsPerComponent 8");
                                if (this.imageInterpolationTable.containsKey(index)) {
                                    this.sw.writeLine("/Interpolate true");
                                }
                                var stMask = "/Length {0} /Filter /FlateDecode";
                                var TmpStream2 = new MemoryStream();
                                TmpStream2.write(mask, 0, mask.length);
                                this.storeMemoryStream2(TmpStream2, stMask);
                                this.sw.writeLine("");
                                this.sw.writeLine("endstream");
                                this.sw.writeLine("endobj");
                                this.sw.writeLine("");
                            }
                        }
                    }
                };
                //#region RenderBookmarksTable
                // 		private void RenderBookmarksTable()
                // {
                //    if (haveBookmarks == true) {
                //        this.addXref(this.info.Outlines.ref);
                //        this.sw.writeLine("{0} 0 obj", this.info.Outlines.ref);
                //        this.sw.writeLine("<<");
                //        this.sw.writeLine("/Type /Outlines");
                //        this.sw.writeLine("/First {0} 0 R", this.info.Outlines.Items[0].ref);
                //        this.sw.writeLine("/Last {0} 0 R", this.info.Outlines.Items[0].ref);
                //        this.sw.writeLine("/Count {0}", 1);
                //        this.sw.writeLine(">>");
                //        this.sw.writeLine("endobj");
                //        this.sw.writeLine("");
                //        for (int index = 0; index < bookmarksCounter; index++)
                //        {
                //            this.addXref(this.info.Outlines.Items[index].ref);
                //            StiBookmarkTreeNode tn = (StiBookmarkTreeNode)bookmarksTree[index];
                //            this.sw.writeLine("{0} 0 obj", this.info.Outlines.Items[index].ref);
                //            this.sw.writeLine("<<");
                //            //					this.sw.writeLine("/Title {0}", ConvertToHexString(tn.Title));
                //            this.storeStringLine("/Title ", tn.Title, true);
                //            if (tn.Parent != -1) this.sw.writeLine("/Parent {0} 0 R", this.info.Outlines.Items[tn.Parent].ref);
                //            if (tn.Prev != -1) this.sw.writeLine("/Prev {0} 0 R", this.info.Outlines.Items[tn.Prev].ref);
                //            if (tn.Next != -1) this.sw.writeLine("/Next {0} 0 R", this.info.Outlines.Items[tn.Next].ref);
                //            if (tn.First != -1) this.sw.writeLine("/First {0} 0 R", this.info.Outlines.Items[tn.First].ref);
                //            if (tn.Last != -1) this.sw.writeLine("/Last {0} 0 R", this.info.Outlines.Items[tn.Last].ref);
                //            if (tn.Count > 0) {
                //                if (index == 0) {
                //                    this.sw.writeLine("/Count {0}", tn.Count);
                //                }
                //                else {
                //                    this.sw.writeLine("/Count {0}", -tn.Count);
                //                }
                //            }
                //            if (tn.Y > -1) this.sw.writeLine("/Dest [{0} 0 R /XYZ null {1} null]", this.info.PageList[tn.Page].Ref, this.convertToString(tn.Y));
                //            this.sw.writeLine(">>");
                //            this.sw.writeLine("endobj");
                //            this.sw.writeLine("");
                //        }
                //    }
                // }
                //#endregion
                StiPdfExportService.prototype.renderPatternTable = function () {
                    this.addXref(this.info.patterns.resources.ref);
                    this.sw.writeLine("{0} 0 obj", this.info.patterns.resources.ref);
                    this.sw.writeLine("<< /ProcSet [/PDF] >>");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                    // render first pattern
                    this.addXref(this.info.patterns.first.ref);
                    this.sw.writeLine("{0} 0 obj", this.info.patterns.first.ref);
                    this.sw.writeLine("<<");
                    this.sw.writeLine("/Type /Pattern");
                    this.sw.writeLine("/PatternType 1");
                    this.sw.writeLine("/PaintType 1");
                    this.sw.writeLine("/TilingType 1");
                    this.sw.writeLine("/BBox [0 0 2 2]");
                    this.sw.writeLine("/XStep 3");
                    this.sw.writeLine("/YStep 3");
                    this.sw.writeLine("/Resources {0} 0 R", this.info.patterns.resources.ref);
                    //
                    this.pageStream = new MemoryStream();
                    this.pageStream.writeLine("1 J 1 j 1 w");
                    this.pageStream.writeLine("1 0 0 RG");
                    this.pageStream.writeString("1 1 m 1.1 1.1 l S");
                    //
                    this.storeMemoryStream2(this.pageStream, "/Length {0}");
                    this.sw.writeLine("");
                    this.sw.writeLine("endstream");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                    if (this.hatchArray.length > 0) {
                        for (var indexHatch = 0; indexHatch < this.hatchArray.length; indexHatch++) {
                            this.writeHatchPattern(indexHatch);
                        }
                    }
                    if (this.shadingArray.length > 0) {
                        for (var indexShading = 0; indexShading < this.shadingArray.length; indexShading++) {
                            this.writeShadingPattern(indexShading);
                        }
                    }
                    this.pageStream.close();
                };
                StiPdfExportService.prototype.writeHatchPattern = function (indexHatch) {
                    var hatch = this.hatchArray[indexHatch];
                    var hatchNumber = hatch.style;
                    if (hatchNumber > 53)
                        hatchNumber = 53;
                    this.addXref(this.info.patterns.hatchItems[indexHatch].ref);
                    this.sw.writeLine("{0} 0 obj", this.info.patterns.hatchItems[indexHatch].ref);
                    this.sw.writeLine("<<");
                    this.sw.writeLine("/Type /Pattern");
                    this.sw.writeLine("/PatternType 1");
                    this.sw.writeLine("/PaintType 1");
                    this.sw.writeLine("/TilingType 1");
                    this.sw.writeLine("/BBox [0 0 1 1]");
                    this.sw.writeLine("/XStep 1");
                    this.sw.writeLine("/YStep 1");
                    this.sw.writeLine("/Resources {0} 0 R", this.info.patterns.resources.ref);
                    this.sw.writeLine("/Matrix [5.5 0 0 5.5 0 0]");
                    //
                    var memsw = new MemoryStream();
                    if (hatch.backColor.a != 0) {
                        memsw.writeLine("{0} {1} {2} rg", this.colorTable[hatch.backColor.r], this.colorTable[hatch.backColor.g], this.colorTable[hatch.backColor.b]);
                        memsw.writeLine("0 0 1 1 re f");
                    }
                    memsw.writeLine("{0} {1} {2} rg", this.colorTable[hatch.foreColor.r], this.colorTable[hatch.foreColor.g], this.colorTable[hatch.foreColor.b]);
                    memsw.writeLine("BI");
                    memsw.writeLine("/W 8");
                    memsw.writeLine("/H 8");
                    memsw.writeLine("/BPC 1");
                    memsw.writeLine("/IM true");
                    memsw.writeLine("/D [1 0]");
                    memsw.writeLine("/F [/AHx]");
                    memsw.writeLine("ID");
                    memsw.writeLine(Export.StiPdfResources.hatchData[hatchNumber] + ">");
                    memsw.writeLine("EI");
                    memsw.flush();
                    //
                    this.storeMemoryStream2(memsw, "/Length {0}");
                    this.sw.writeLine("endstream");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                };
                StiPdfExportService.prototype.writeShadingPattern = function (indexShading) {
                    var ssd = this.shadingArray[indexShading];
                    var xs = 1;
                    var ys = 1;
                    var angle = ssd.Angle;
                    if (angle < 0)
                        angle += 360;
                    if ((angle >= 270) && (angle < 360)) {
                        angle = 360 - angle;
                        ys = -1;
                    }
                    if ((angle >= 180) && (angle < 270)) {
                        angle = angle - 180;
                        ys = -1;
                        xs = -1;
                    }
                    if ((angle >= 90) && (angle < 180)) {
                        angle = 180 - angle;
                        xs = -1;
                    }
                    angle = angle * Math.PI / 180;
                    var x0 = ssd.X + ssd.Width / 2;
                    var y0 = ssd.Y + ssd.Height / 2;
                    var r = Math.sqrt(ssd.Width * ssd.Width + ssd.Height * ssd.Height) / 2;
                    var a2 = Math.atan2(ssd.Height, ssd.Width);
                    var st = Math.PI / 2 - angle + a2;
                    var b = r * Math.sin(st);
                    var xr = b * Math.cos(angle) * xs;
                    var yr = b * Math.sin(angle) * ys;
                    var x1 = x0 - xr;
                    var x2 = x0 + xr;
                    var y1 = y0 + yr;
                    var y2 = y0 - yr;
                    this.addXref(this.info.patterns.shadingItems[indexShading].ref);
                    this.sw.writeLine("{0} 0 obj", this.info.patterns.shadingItems[indexShading].ref);
                    this.sw.writeLine("<<");
                    this.sw.writeLine("/PatternType 2");
                    this.sw.writeLine("/Shading <<");
                    this.sw.writeLine("/ColorSpace /DeviceRGB");
                    this.sw.writeLine("/ShadingType 2");
                    this.sw.writeLine("/Coords [ {0} {1} {2} {3} ]", this.convertToString(x1), this.convertToString(y1), this.convertToString(x2), this.convertToString(y2));
                    this.sw.writeLine("/Extend [ true true ]");
                    this.sw.writeLine("/Function {0} 0 R", this.info.patterns.shadingItems[indexShading].function.ref);
                    this.sw.writeLine(">>");
                    this.sw.writeLine(">>");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                    this.addXref(this.info.patterns.shadingItems[indexShading].function.ref);
                    this.sw.writeLine("{0} 0 obj", this.info.patterns.shadingItems[indexShading].function.ref);
                    this.sw.writeLine("<<");
                    this.sw.writeLine("/FunctionType 0");
                    this.sw.writeLine("/Size [ 3 ]");
                    this.sw.writeLine("/Decode [ 0 1 0 1 0 1 ]");
                    this.sw.writeLine("/Range [ 0 1 0 1 0 1 ]");
                    this.sw.writeLine("/BitsPerSample 8");
                    this.sw.writeLine("/Domain [ 0 1 ]");
                    this.sw.writeLine("/Encode [ 0 {0} ]", ssd.IsGlare ? 2 : 1);
                    this.sw.writeLine("/Order 1");
                    //
                    var memsw = new MemoryStream();
                    memsw.writeByte(ssd.Color1.r);
                    memsw.writeByte(ssd.Color1.g);
                    memsw.writeByte(ssd.Color1.b);
                    memsw.writeByte(ssd.Color2.r);
                    memsw.writeByte(ssd.Color2.g);
                    memsw.writeByte(ssd.Color2.b);
                    memsw.writeByte(ssd.Color1.r);
                    memsw.writeByte(ssd.Color1.g);
                    memsw.writeByte(ssd.Color1.b);
                    //
                    this.storeMemoryStream2(memsw, "/Length {0}");
                    this.sw.writeLine("");
                    this.sw.writeLine("endstream");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                };
                //#region RenderLinkTable
                // 		private void RenderLinkTable()
                // {
                //    if (haveLinks == true) {
                //        for (int index = 0; index < linksCounter; index++)
                //        {
                //            StiLinkObject stl = (StiLinkObject)linksArray[index];
                //            //check link - intenal or external; if internal - get destination
                //            if (stl.Link.sti.startsWith("##") && tagsArray.Count > 0) {
                //                //internal link to tag
                //                string st = stl.Link.Substr(2);
                //                for (int indexTag = 0; indexTag < tagsArray.Count; indexTag++)
                //                {
                //                    StiLinkObject tag = tagsArray[indexTag];
                //                    if (tag.Link == st) {
                //                        stl.DestPage = tag.Page;
                //                        stl.DestY = tag.Y;
                //                        break;
                //                    }
                //                }
                //            }
                //            else {
                //                //internal link to bookmark
                //                if ((stl.Link[0] == '#') && (haveBookmarks == true)) {
                //                    string st = stl.Link.substr(1);
                //                    if ((st[0] == '%') && (st.Length > 2)) {
                //                        int pos = st.LastIndexOf(st[1]);
                //                        if (pos < st.Length - 1) {
                //                            st = st.substr(pos + 1);
                //                        }
                //                    }
                //                    for (int indexBookmark = 0; indexBookmark < bookmarksCounter; indexBookmark++)
                //                    {
                //                        StiBookmarkTreeNode tn = (StiBookmarkTreeNode)bookmarksTree[indexBookmark];
                //                        if (tn.Title == st) {
                //                            stl.DestPage = tn.Page;
                //                            stl.DestY = tn.Y;
                //                            break;
                //                        }
                //                    }
                //                }
                //            }
                //            linksArray[index] = stl;
                //            this.addXref(this.info.LinkList[index].ref);
                //            this.sw.writeLine("{0} 0 obj", this.info.LinkList[index].ref);
                //            this.sw.writeLine("<<");
                //            this.sw.writeLine("/Type /Annot");
                //            this.sw.writeLine("/Subtype /Link");
                //            this.sw.writeLine("/Rect [{0} {1} {2} {3}]", this.convertToString(stl.X), this.convertToString(stl.Y), this.convertToString(stl.X + stl.Width), this.convertToString(stl.Y + stl.Height));
                //            this.sw.writeLine("/Border [0 0 0]");
                //            if (stl.Link[0] == '#') {
                //                if (stl.DestY > -1) this.sw.writeLine("/Dest [{0} 0 R /XYZ null {1} null]", this.info.PageList[stl.DestPage].Ref, this.convertToString(stl.DestY));
                //                else this.sw.writeLine("/Dest [{0} 0 R /XYZ null null null]", this.info.PageList[0].ref);
                //            }
                //            else {
                //                string link = this.stringReplace(stl.Link, '\\', '/');
                //                bool flag = (link.Length > 6) &&
                //                (char.IsLetter(link, 0) && (link[1] == ':') && (link[2] == '/')) ||
                //                ((link[0] == '/') && char.IsLetter(link, 1) && (link[2] == '/'));
                //                if (flag && (link[1] == ':')) link = "/" + link[0] + link.substr(2);
                //                this.sw.writeLine("/A <<");
                //                this.sw.writeLine("/Type /Action");
                //                if (flag) {
                //                    this.sw.writeLine("/S /Launch");
                //                    this.sw.writeLine("/F <<");
                //                    this.sw.writeLine("/Type /Filespec");
                //                    this.storeStringLine("/F ", link);
                //                    this.storeStringLine("/UF ", link);
                //                    this.sw.writeLine(">>");
                //                }
                //                else {
                //                    this.sw.writeLine("/S /URI");
                //                    this.storeStringLine("/URI ", StiExportUtils.StringToUrl(link));
                //                }
                //                this.sw.writeLine(">>");
                //            }
                //            this.sw.writeLine(">>");
                //            this.sw.writeLine("endobj");
                //            this.sw.writeLine("");
                //        }
                //    }
                // }
                //#endregion
                //#region RenderAnnotTable
                StiPdfExportService.prototype.renderAnnotTable = function () {
                    if (this.haveAnnots || this.haveDigitalSignature || this.haveTooltips) {
                        //#region AcroForm object
                        this.addXref(this.info.acroForm.ref);
                        this.sw.writeLine("{0} 0 obj", this.info.acroForm.ref);
                        this.sw.writeLine("<<");
                        this.sw.writeLine("/Fields [");
                        for (var index = 0; index < this.annotsCounter; index++) {
                            this.sw.writeLine("{0} 0 R", this.info.acroForm.annots[index].ref);
                        }
                        for (var index = 0; index < this.annots2Counter; index++) {
                            for (var indexState = 0; indexState < this.info.acroForm.checkBoxes[index].items.length; indexState++) {
                                this.sw.writeLine("{0} 0 R", this.info.acroForm.checkBoxes[index].items[indexState].ref);
                            }
                        }
                        for (var index = 0; index < this.unsignedSignaturesCounter; index++) {
                            this.sw.writeLine("{0} 0 R", this.info.acroForm.unsignedSignatures[index].ref);
                        }
                        if (this.haveDigitalSignature) {
                            this.sw.writeLine("{0} 0 R", this.info.acroForm.signatures[0].ref);
                        }
                        for (var index = 0; index < this.tooltipsCounter; index++) {
                            this.sw.writeLine("{0} 0 R", this.info.acroForm.tooltips[index].ref);
                        }
                        this.sw.writeLine("]");
                        this.sw.writeLine("/DR <<");
                        if (this.annotsCounter > 0 || this.annots2Counter > 0) {
                            this.sw.writeLine("/Font <<");
                            for (var index = 0; index < this.fontsCounter; index++) {
                                this.sw.writeLine("/FA{0} {1} 0 R", index, this.info.acroForm.annotFontItems[index].ref);
                            }
                            this.sw.writeLine(">>");
                        }
                        this.sw.writeLine(">>");
                        if (this.haveAnnots && (this.fontsCounter > 0)) {
                            this.storeStringLine("/DA ", "/FA0 0 Tf 0 g");
                        }
                        if (this.haveDigitalSignature) {
                            this.sw.writeLine("/SigFlags 3");
                        }
                        this.sw.writeLine(">>");
                        this.sw.writeLine("endobj");
                        this.sw.writeLine("");
                        //#endregion
                        if (this.haveAnnots) {
                            var fieldsNames = new Hashtable();
                            for (var index = 0; index < this.annotsCounter; index++) {
                                var seo = this.annotsArray[index];
                                //#region make field name
                                var fieldName = "";
                                if (StiOptions.Export.Pdf.useEditableFieldName)
                                    fieldName = seo.Component.name;
                                if (StiOptions.Export.Pdf.useEditableFieldAlias)
                                    fieldName = seo.Component.alias;
                                if (StiOptions.Export.Pdf.useEditableFieldTag)
                                    fieldName = seo.Component.tagValue;
                                if (StiString.isNullOrEmpty(fieldName))
                                    fieldName = StiString.format("Field{0}", index);
                                if (fieldsNames.containsKey(fieldName)) {
                                    var indexName = 2;
                                    var nameAdd = "";
                                    while (fieldsNames.containsKey(fieldName + nameAdd)) {
                                        nameAdd = "_" + indexName.toString();
                                        indexName++;
                                    }
                                    fieldName = fieldName + nameAdd;
                                }
                                fieldsNames.add(fieldName, fieldName);
                                //#endregion
                                //#region Annot object
                                this.addXref(this.info.acroForm.annots[index].ref);
                                this.sw.writeLine("{0} 0 obj", this.info.acroForm.annots[index].ref);
                                this.sw.writeLine("<<");
                                this.sw.writeLine("/Type /Annot");
                                this.sw.writeLine("/Subtype /Widget");
                                this.sw.writeLine("/Rect [{0} {1} {2} {3}]", this.convertToString(seo.X), this.convertToString(seo.Y), this.convertToString(seo.X + seo.Width), this.convertToString(seo.Y + seo.Height));
                                this.sw.writeLine("/F 4");
                                this.sw.writeLine("/P {0} 0 R", this.info.pageList[seo.Page].ref);
                                this.sw.writeLine("/FT /Tx");
                                this.sw.writeLine("/BS << /W 0 >>");
                                this.storeStringLine("/T ", fieldName);
                                this.sw.writeLine("/MK << /TP 2 >>");
                                this.sw.writeLine("/H /P");
                                this.sw.writeLine("/AP << /N {0} 0 R >>", this.info.acroForm.annots[index].aP.ref);
                                var flagFf = seo.Multiline ? 0x1000 : 0;
                                if (((seo.Component.sti.as(StiText)) != null) && (seo.Component.sti.as(StiText).TextOptions != null)) {
                                    if (seo.Component.sti.as(StiText).TextOptions.LineLimit)
                                        flagFf |= 0x800000;
                                }
                                this.sw.writeLine("/Ff {0}", flagFf);
                                this.storeStringLine("/DA ", StiString.format("/FA{0} {1} Tf {2} {3} {4} rg", seo.FontNumber, this.convertToString(seo.FontSize, this.precision_digits_font), this.colorTable[seo.FontColor.r], this.colorTable[seo.FontColor.g], this.colorTable[seo.FontColor.b]));
                                this.storeStringLine("/V ", seo.Text);
                                this.storeStringLine("/DV ", seo.Text);
                                this.sw.writeLine("/Q {0}", (seo.Alignment == Stimulsoft.Base.Drawing.StiTextHorAlignment.Center ? 1 : 0) +
                                    (seo.Alignment == Stimulsoft.Base.Drawing.StiTextHorAlignment.Right ? 2 : 0));
                                this.sw.writeLine(">>");
                                this.sw.writeLine("endobj");
                                this.sw.writeLine("");
                                //#endregion
                                //#region / AP object
                                this.addXref(this.info.acroForm.annots[index].aP.ref);
                                this.sw.writeLine("{0} 0 obj", this.info.acroForm.annots[index].aP.ref);
                                this.sw.writeLine("<<");
                                this.sw.writeLine("/Subtype /Form");
                                this.sw.writeLine("/BBox [{0} {1} {2} {3}]", this.convertToString(0), this.convertToString(0), this.convertToString(seo.Width), this.convertToString(seo.Height));
                                this.sw.writeLine("/Resources <<");
                                this.sw.writeLine("/ProcSet [ /PDF /Text ]");
                                this.sw.writeLine("/Font << /F{0} {1} 0 R >> >>", seo.FontNumber, this.info.fontList[seo.FontNumber].ref);
                                var annotSw = new MemoryStream();
                                // stream
                                annotSw.writeLine("/Tx BMC");
                                annotSw.writeLine("q");
                                var borderOffset = 1;
                                annotSw.writeLine("{0} {1} {2} {3} re W n", this.convertToString(borderOffset), this.convertToString(borderOffset), this.convertToString(seo.Width - borderOffset), this.convertToString(seo.Height - borderOffset));
                                annotSw.flush();
                                annotSw.write(seo.Content, 0, seo.Content.length);
                                annotSw.writeLine("Q");
                                annotSw.writeLine("EMC");
                                annotSw.flush();
                                this.storeMemoryStream2(annotSw, "/Filter [] /Length {0}");
                                this.sw.writeLine("");
                                annotSw.close();
                                this.sw.writeLine("endstream");
                                this.sw.writeLine("endobj");
                                this.sw.writeLine("");
                                //#endregion
                            }
                            for (var indexFont = 0; indexFont < this.fontsCounter; indexFont++) {
                                //#region Annot font
                                this.pdfFont.currentFont = indexFont;
                                var tempInfo = this.pdfFont.fontList[indexFont];
                                var fontName = tempInfo.Name;
                                if (StiOptions.Export.Pdf.useAlternativeFontNames && StiOptions.Export.Pdf.alternativeFontNames.containsKey(fontName)) {
                                    fontName = StiOptions.Export.Pdf.alternativeFontNames.get(fontName);
                                }
                                var tempSb = new StringBuilder(this.stringReplace(fontName, " ", "#20"));
                                if (tempInfo.Bold || tempInfo.Italic) {
                                    tempSb.append(",");
                                    if (tempInfo.Bold)
                                        tempSb.append("Bold");
                                    if (tempInfo.Italic)
                                        tempSb.append("Italic");
                                }
                                this.addXref(this.info.acroForm.annotFontItems[indexFont].ref);
                                this.sw.writeLine("{0} 0 obj", this.info.acroForm.annotFontItems[indexFont].ref);
                                this.sw.writeLine("<<");
                                this.sw.writeLine("/Type /Font");
                                this.sw.writeLine("/Subtype /TrueType");
                                this.sw.writeLine("/Name /FA{0}", indexFont);
                                this.sw.writeLine("/BaseFont /{0}", tempSb);
                                this.sw.writeLine("/Encoding /WinAnsiEncoding");
                                this.sw.writeLine("/FontDescriptor {0} 0 R", this.info.acroForm.annotFontItems[indexFont].fontDescriptor.ref);
                                if (this.fontGlyphsReduceNotNeed[indexFont]) {
                                    // make string "Widths"
                                    var sbWidths = new StringBuilder(" ");
                                    for (var indexUni = 32; indexUni < 256; indexUni++) {
                                        sbWidths.append(this.pdfFont.Widths[this.pdfFont.UnicodeMap[this.CodePage1252[indexUni]] - 32].toString() + " ");
                                    }
                                    this.sw.writeLine("/FirstChar 32");
                                    this.sw.writeLine("/LastChar 255");
                                    this.sw.writeLine("/Widths [{0}]", sbWidths);
                                }
                                this.sw.writeLine(">>");
                                this.sw.writeLine("endobj");
                                this.sw.writeLine("");
                                this.addXref(this.info.acroForm.annotFontItems[indexFont].fontDescriptor.ref);
                                this.sw.writeLine("{0} 0 obj", this.info.acroForm.annotFontItems[indexFont].fontDescriptor.ref);
                                this.sw.writeLine("<<");
                                this.sw.writeLine("/Type /FontDescriptor");
                                this.sw.writeLine("/FontName /{0}", tempSb);
                                this.sw.writeLine("/Flags 32");
                                this.sw.writeLine("/Ascent {0}", this.pdfFont.tmASC); // MacAscend
                                this.sw.writeLine("/CapHeight {0}", this.pdfFont.CH);
                                this.sw.writeLine("/Descent {0}", -this.pdfFont.tmDESC); // MacDescend
                                // this.sw.writeLine("/FontBBox [{0} {1} {2} {3}]", this.pdfFont.LLX, this.pdfFont.LLY, this.pdfFont.URX, this.pdfFont.URY);
                                this.sw.writeLine("/FontBBox [{0} {1} {2} {3}]", -500, -200, 1500, 1000);
                                this.sw.writeLine("/ItalicAngle {0}", this.pdfFont.ItalicAngle);
                                this.sw.writeLine("/StemV {0}", this.pdfFont.StemV);
                                if (this.embeddedFonts == true) {
                                    this.sw.writeLine("/FontFile2 {0} 0 R", this.info.fontList[indexFont].fontFile2.ref);
                                }
                                this.sw.writeLine(">>");
                                this.sw.writeLine("endobj");
                                this.sw.writeLine("");
                                //#endregion
                            }
                            for (var index = 0; index < this.annots2Counter; index++) {
                                var seo = this.annots2Array[index];
                                //#region make field name
                                var fieldName = "";
                                if (StiOptions.Export.Pdf.useEditableFieldName)
                                    fieldName = seo.Component.name;
                                if (StiOptions.Export.Pdf.useEditableFieldAlias)
                                    fieldName = seo.Component.alias;
                                if (StiOptions.Export.Pdf.useEditableFieldTag)
                                    fieldName = seo.Component.tagValue;
                                if (StiString.isNullOrEmpty(fieldName))
                                    fieldName = StiString.format("Checkbox{0}", index + 1);
                                if (fieldsNames.containsKey(fieldName)) {
                                    var indexName = 2;
                                    var nameAdd = "";
                                    while (fieldsNames.containsKey(fieldName + nameAdd)) {
                                        nameAdd = "_" + indexName.toString();
                                        indexName++;
                                    }
                                    fieldName = fieldName + nameAdd;
                                }
                                fieldsNames.add(fieldName, fieldName);
                                //#endregion
                                var checkboxSizeCorrection = 0.01;
                                var checkbox = seo.Component.sti.as(StiCheckBox);
                                var checkBoxValue = Export.StiPdfRenderPrimitives.getCheckBoxValue(checkbox);
                                if (checkBoxValue == null)
                                    checkBoxValue = false;
                                if (this.info.acroForm.checkBoxes[index].items.length > 1) {
                                    //#region Annot object - Yes
                                    var annot = this.info.acroForm.checkBoxes[index].items[0];
                                    this.addXref(annot.ref);
                                    this.sw.writeLine("{0} 0 obj", annot.ref);
                                    this.sw.writeLine("<<");
                                    this.sw.writeLine("/Type /Annot");
                                    this.sw.writeLine("/Subtype /Widget");
                                    this.sw.writeLine("/FT /Btn");
                                    this.sw.writeLine("/Rect [{0} {1} {2} {3}]", this.convertToString(seo.X), this.convertToString(seo.Y), this.convertToString(seo.X + seo.Width - checkboxSizeCorrection), this.convertToString(seo.Y + seo.Height - checkboxSizeCorrection));
                                    this.sw.writeLine("/F {0}", 4 + (this.info.acroForm.checkBoxes[index].items.length == 3 || (checkBoxValue == false) ? 2 : 0));
                                    this.sw.writeLine("/P {0} 0 R", this.info.pageList[seo.Page].ref);
                                    this.storeStringLine("/T ", fieldName + "Yes");
                                    this.sw.writeLine("/MK << >>");
                                    this.sw.writeLine("/Ff 65536");
                                    this.sw.writeLine("/A {0} 0 R", annot.aA[0].ref);
                                    this.sw.writeLine("/AP << /N {0} 0 R >>", annot.aP.ref);
                                    this.sw.writeLine("/H /O");
                                    this.sw.writeLine(">>");
                                    this.sw.writeLine("endobj");
                                    this.sw.writeLine("");
                                    //#endregion
                                    //#region / AP object
                                    this.addXref(annot.aP.ref);
                                    this.sw.writeLine("{0} 0 obj", annot.aP.ref);
                                    this.sw.writeLine("<<");
                                    this.sw.writeLine("/Type /XObject");
                                    this.sw.writeLine("/Subtype /Form");
                                    this.sw.writeLine("/FormType 1");
                                    this.sw.writeLine("/BBox [{0} {1} {2} {3}]", this.convertToString(0), this.convertToString(0), this.convertToString(seo.Width), this.convertToString(seo.Height));
                                    this.sw.writeLine("/Matrix [ 1 0 0 1 0 0 ]");
                                    this.sw.writeLine("/Resources <<");
                                    this.sw.writeLine("/ProcSet [ /PDF ]");
                                    this.sw.writeLine("/Pattern");
                                    this.sw.writeLine("<<");
                                    for (var indexPattern = 0; indexPattern < this.hatchArray.length; indexPattern++) {
                                        this.sw.writeLine(StiString.format("/PH{0} {1} 0 R", 1 + indexPattern, this.info.patterns.hatchItems[indexPattern].ref));
                                    }
                                    for (var indexPattern = 0; indexPattern < this.shadingArray.length; indexPattern++) {
                                        this.sw.writeLine(StiString.format("/P{0} {1} 0 R", 2 + indexPattern, this.info.patterns.shadingItems[indexPattern].ref));
                                    }
                                    this.sw.writeLine(">>");
                                    this.sw.writeLine("/ColorSpace 3 0 R");
                                    this.sw.writeLine(">>");
                                    var annotSw = new MemoryStream();
                                    // stream
                                    annotSw.writeLine("/Tx BMC");
                                    annotSw.writeLine("q");
                                    var borderOffset = 1;
                                    annotSw.writeLine("{0} {1} {2} {3} re W n", this.convertToString(borderOffset), this.convertToString(borderOffset), this.convertToString(seo.Width - borderOffset), this.convertToString(seo.Height - borderOffset));
                                    annotSw.flush();
                                    annotSw.write(seo.Content, 0, seo.Content.length);
                                    annotSw.writeLine("Q");
                                    annotSw.writeLine("EMC");
                                    annotSw.flush();
                                    this.storeMemoryStream2(annotSw, "/Filter [] /Length {0}");
                                    this.sw.writeLine("");
                                    annotSw.close();
                                    this.sw.writeLine("endstream");
                                    this.sw.writeLine("endobj");
                                    this.sw.writeLine("");
                                    //#endregion
                                    //#region / AA objects
                                    this.addXref(annot.aA[0].ref);
                                    this.sw.writeLine("{0} 0 obj", annot.aA[0].ref);
                                    this.sw.writeLine("<<");
                                    this.sw.writeLine("/Next {0} 0 R", annot.aA[1].ref);
                                    this.sw.writeLine("/S /Hide");
                                    this.sw.writeLine("/T ({0})", fieldName + "Yes");
                                    this.sw.writeLine(">>");
                                    this.sw.writeLine("endobj");
                                    this.sw.writeLine("");
                                    this.addXref(annot.aA[1].ref);
                                    this.sw.writeLine("{0} 0 obj", annot.aA[1].ref);
                                    this.sw.writeLine("<<");
                                    this.sw.writeLine("/H false");
                                    this.sw.writeLine("/S /Hide");
                                    this.sw.writeLine("/T ({0})", fieldName + "No");
                                    this.sw.writeLine(">>");
                                    this.sw.writeLine("endobj");
                                    this.sw.writeLine("");
                                    //#endregion
                                    //#region Annot object - No
                                    annot = this.info.acroForm.checkBoxes[index].items[1];
                                    this.addXref(annot.ref);
                                    this.sw.writeLine("{0} 0 obj", annot.ref);
                                    this.sw.writeLine("<<");
                                    this.sw.writeLine("/Type /Annot");
                                    this.sw.writeLine("/Subtype /Widget");
                                    this.sw.writeLine("/FT /Btn");
                                    this.sw.writeLine("/Rect [{0} {1} {2} {3}]", this.convertToString(seo.X), this.convertToString(seo.Y), this.convertToString(seo.X + seo.Width - checkboxSizeCorrection), this.convertToString(seo.Y + seo.Height - checkboxSizeCorrection));
                                    this.sw.writeLine("/F {0}", 4 + (this.info.acroForm.checkBoxes[index].items.length == 3 || (checkBoxValue == true) ? 2 : 0));
                                    this.sw.writeLine("/P {0} 0 R", this.info.pageList[seo.Page].ref);
                                    this.storeStringLine("/T ", fieldName + "No");
                                    this.sw.writeLine("/MK << >>");
                                    this.sw.writeLine("/Ff 65536");
                                    this.sw.writeLine("/A {0} 0 R", annot.aA[0].ref);
                                    this.sw.writeLine("/AP << /N {0} 0 R >>", annot.aP.ref);
                                    this.sw.writeLine("/H /O");
                                    this.sw.writeLine(">>");
                                    this.sw.writeLine("endobj");
                                    this.sw.writeLine("");
                                    //#endregion
                                    //#region / AP object
                                    this.addXref(annot.aP.ref);
                                    this.sw.writeLine("{0} 0 obj", annot.aP.ref);
                                    this.sw.writeLine("<<");
                                    this.sw.writeLine("/Type /XObject");
                                    this.sw.writeLine("/Subtype /Form");
                                    this.sw.writeLine("/FormType 1");
                                    this.sw.writeLine("/BBox [{0} {1} {2} {3}]", this.convertToString(0), this.convertToString(0), this.convertToString(seo.Width), this.convertToString(seo.Height));
                                    this.sw.writeLine("/Matrix [ 1 0 0 1 0 0 ]");
                                    this.sw.writeLine("/Resources <<");
                                    this.sw.writeLine("/ProcSet [ /PDF ]");
                                    this.sw.writeLine("/Pattern");
                                    this.sw.writeLine("<<");
                                    for (var indexPattern = 0; indexPattern < this.hatchArray.length; indexPattern++) {
                                        this.sw.writeLine(StiString.format("/PH{0} {1} 0 R", 1 + indexPattern, this.info.patterns.hatchItems[indexPattern].ref));
                                    }
                                    for (var indexPattern = 0; indexPattern < this.shadingArray.length; indexPattern++) {
                                        this.sw.writeLine(StiString.format("/P{0} {1} 0 R", 2 + indexPattern, this.info.patterns.shadingItems[indexPattern].ref));
                                    }
                                    this.sw.writeLine(">>");
                                    this.sw.writeLine("/ColorSpace 3 0 R");
                                    this.sw.writeLine(">>");
                                    annotSw = new MemoryStream();
                                    // stream
                                    annotSw.writeLine("/Tx BMC");
                                    annotSw.writeLine("q");
                                    borderOffset = 1;
                                    annotSw.writeLine("{0} {1} {2} {3} re W n", this.convertToString(borderOffset), this.convertToString(borderOffset), this.convertToString(seo.Width - borderOffset), this.convertToString(seo.Height - borderOffset));
                                    annotSw.flush();
                                    annotSw.write(seo.Content2, 0, seo.Content2.length);
                                    annotSw.writeLine("Q");
                                    annotSw.writeLine("EMC");
                                    annotSw.flush();
                                    this.storeMemoryStream2(annotSw, "/Filter [] /Length {0}");
                                    this.sw.writeLine("");
                                    annotSw.close();
                                    this.sw.writeLine("endstream");
                                    this.sw.writeLine("endobj");
                                    this.sw.writeLine("");
                                    //#endregion
                                    //#region / AA objects
                                    this.addXref(annot.aA[0].ref);
                                    this.sw.writeLine("{0} 0 obj", annot.aA[0].ref);
                                    this.sw.writeLine("<<");
                                    this.sw.writeLine("/H false");
                                    this.sw.writeLine("/Next {0} 0 R", annot.aA[1].ref);
                                    this.sw.writeLine("/S /Hide");
                                    this.sw.writeLine("/T ({0})", fieldName + "Yes");
                                    this.sw.writeLine(">>");
                                    this.sw.writeLine("endobj");
                                    this.sw.writeLine("");
                                    this.addXref(annot.aA[1].ref);
                                    this.sw.writeLine("{0} 0 obj", annot.aA[1].ref);
                                    this.sw.writeLine("<<");
                                    this.sw.writeLine("/S /Hide");
                                    this.sw.writeLine("/T ({0})", fieldName + "No");
                                    this.sw.writeLine(">>");
                                    this.sw.writeLine("endobj");
                                    this.sw.writeLine("");
                                    //#endregion
                                }
                                if (this.info.acroForm.checkBoxes[index].items.length == 3) {
                                    //#region Annot object - None
                                    var annot = this.info.acroForm.checkBoxes[index].items[2];
                                    this.addXref(annot.ref);
                                    this.sw.writeLine("{0} 0 obj", annot.ref);
                                    this.sw.writeLine("<<");
                                    this.sw.writeLine("/Type /Annot");
                                    this.sw.writeLine("/Subtype /Widget");
                                    this.sw.writeLine("/FT /Btn");
                                    this.sw.writeLine("/Rect [{0} {1} {2} {3}]", this.convertToString(seo.X), this.convertToString(seo.Y), this.convertToString(seo.X + seo.Width - checkboxSizeCorrection), this.convertToString(seo.Y + seo.Height - checkboxSizeCorrection));
                                    this.sw.writeLine("/F 4");
                                    this.sw.writeLine("/P {0} 0 R", this.info.pageList[seo.Page].ref);
                                    this.storeStringLine("/T ", fieldName + "None");
                                    this.sw.writeLine("/MK << >>");
                                    this.sw.writeLine("/Ff 65536");
                                    this.sw.writeLine("/A {0} 0 R", annot.aA[0].ref);
                                    this.sw.writeLine("/H /O");
                                    this.sw.writeLine(">>");
                                    this.sw.writeLine("endobj");
                                    this.sw.writeLine("");
                                    //#endregion
                                    //#region / AA objects
                                    this.addXref(annot.aA[0].ref);
                                    this.sw.writeLine("{0} 0 obj", annot.aA[0].ref);
                                    this.sw.writeLine("<<");
                                    this.sw.writeLine("/Next {0} 0 R", annot.aA[1].ref);
                                    this.sw.writeLine("/S /Hide");
                                    this.sw.writeLine("/T ({0})", fieldName + "None");
                                    this.sw.writeLine(">>");
                                    this.sw.writeLine("endobj");
                                    this.sw.writeLine("");
                                    this.addXref(annot.aA[1].ref);
                                    this.sw.writeLine("{0} 0 obj", annot.aA[1].ref);
                                    this.sw.writeLine("<<");
                                    this.sw.writeLine("/H false");
                                    this.sw.writeLine("/S /Hide");
                                    this.sw.writeLine("/T ({0})", fieldName + (checkbox.checkStyleForTrue == Stimulsoft.Report.Components.StiCheckStyle.None ? "No" : "Yes"));
                                    this.sw.writeLine(">>");
                                    this.sw.writeLine("endobj");
                                    this.sw.writeLine("");
                                    //#endregion
                                }
                            }
                            for (var index = 0; index < this.unsignedSignaturesCounter; index++) {
                                var seo = this.unsignedSignaturesArray[index];
                                //#region make field name
                                var fieldName = "";
                                if (StiOptions.Export.Pdf.useEditableFieldName)
                                    fieldName = seo.Component.name;
                                if (StiOptions.Export.Pdf.useEditableFieldAlias)
                                    fieldName = seo.Component.alias;
                                if (StiOptions.Export.Pdf.useEditableFieldTag)
                                    fieldName = seo.Component.tagValue;
                                if (StiString.isNullOrEmpty(fieldName))
                                    fieldName = StiString.format("UnsignedSignature{0}", index);
                                if (fieldsNames.containsKey(fieldName)) {
                                    var indexName = 2;
                                    var nameAdd = "";
                                    while (fieldsNames.containsKey(fieldName + nameAdd)) {
                                        nameAdd = "_" + indexName.toString();
                                        indexName++;
                                    }
                                    fieldName = fieldName + nameAdd;
                                }
                                fieldsNames.add(fieldName, fieldName);
                                //#endregion
                                //#region Annot object
                                var indexOffset3 = this.info.acroForm.unsignedSignatures[index].ref;
                                this.addXref(indexOffset3);
                                this.sw.writeLine("{0} 0 obj", indexOffset3);
                                this.sw.writeLine("<<");
                                this.sw.writeLine("/Type /Annot");
                                this.sw.writeLine("/Subtype /Widget");
                                this.sw.writeLine("/Rect [{0} {1} {2} {3}]", this.convertToString(seo.X), this.convertToString(seo.Y), this.convertToString(seo.X + seo.Width), this.convertToString(seo.Y + seo.Height));
                                this.sw.writeLine("/F 4");
                                this.sw.writeLine("/P {0} 0 R", this.info.pageList[seo.Page].ref);
                                this.sw.writeLine("/FT /Sig");
                                this.storeStringLine("/T ", fieldName);
                                this.sw.writeLine("/MK << >>");
                                this.sw.writeLine(">>");
                                this.sw.writeLine("endobj");
                                this.sw.writeLine("");
                                //#endregion
                            }
                        }
                    }
                };
                //#endregion
                //#region RenderSignatureTable
                // 		private void RenderSignatureTable(StiReport report)
                // {
                //    if (haveDigitalSignature == true) {
                //        string signedBy = "Stimulsoft Reports.Net";
                //        if (!string.IsNullOrEmpty(digitalSignatureSignedBy)) {
                //            signedBy = digitalSignatureSignedBy;
                //        }
                //        this.addXref(this.info.AcroForm.Signatures[0].ref);
                //        this.sw.writeLine("{0} 0 obj", this.info.AcroForm.Signatures[0].ref);
                //        this.sw.writeLine("<<");
                //        this.sw.writeLine("/Rect [{0} {1} {2} {3}]",
                //            this.convertToString(signaturePlacement.Left),
                //            this.convertToString(signaturePlacement.Bottom),
                //            this.convertToString(signaturePlacement.Right),
                //            this.convertToString(signaturePlacement.Top));
                //        this.sw.writeLine("/Type /Annot");
                //        this.sw.writeLine("/Subtype /Widget");
                //        this.sw.writeLine("/F 132");
                //        this.sw.writeLine("/P {0} 0 R", this.info.PageList[signaturePageNumber].ref);
                //        this.storeStringLine("/T ", "Signature1");
                //        this.sw.writeLine("/V {0} 0 R", this.info.AcroForm.Signatures[0].AP.ref);
                //        this.storeStringLine("/DA ", "0 g");
                //        this.sw.writeLine("/FT /Sig");
                //        this.sw.writeLine("/MK<<>>");
                //        this.sw.writeLine(">>");
                //        this.sw.writeLine("endobj");
                //        this.sw.writeLine("");
                //        this.addXref(this.info.AcroForm.Signatures[0].AP.ref);
                //        this.sw.writeLine("{0} 0 obj", this.info.AcroForm.Signatures[0].AP.ref);
                //        this.sw.writeLine("<<");
                //        this.sw.writeLine("/Type /Sig");
                //        sw.Write("/Filter /");
                //        sw.Flush();
                //        offsetSignatureFilter = (int)(sw.BaseStream.Position);
                //        this.sw.writeLine("Adobe.PPKLite          ");
                //        this.sw.writeLine("/SubFilter /adbe.pkcs7.detached");
                //        //this.storeStringLine("/Name ", signedBy);
                //        sw.Write("/Name ");
                //        sw.Flush();
                //        offsetSignatureName = (int)(sw.BaseStream.Position);
                //        string tempSt = ConvertToHexString(signedBy, false);
                //        if (string.IsNullOrEmpty(digitalSignatureSignedBy)) {
                //            tempSt += new string(' ', 128 - tempSt.Length);
                //        }
                //        this.sw.writeLine(tempSt);
                //        sw.Write("/Contents<{0}>", new string('0', signatureDataLen));
                //        sw.Flush();
                //        offsetSignatureData = (int)(sw.BaseStream.Position - signatureDataLen - 2);
                //        this.sw.writeLine("");
                //        this.storeStringLine("/M ", currentDateTime);
                //        if (!string.IsNullOrEmpty(digitalSignatureReason)) {
                //            this.storeStringLine("/Reason ", digitalSignatureReason);
                //        }
                //        if (!string.IsNullOrEmpty(digitalSignatureLocation)) {
                //            this.storeStringLine("/Location ", digitalSignatureLocation);
                //        }
                //        if (!string.IsNullOrEmpty(digitalSignatureContactInfo)) {
                //            this.storeStringLine("/ContactInfo ", digitalSignatureContactInfo);
                //        }
                //        sw.Write("/ByteRange [0 {0} {1} ",
                //            offsetSignatureData,
                //            offsetSignatureData + signatureDataLen + 2);
                //        sw.Flush();
                //        offsetSignatureLen2 = (int)(sw.BaseStream.Position);
                //        this.sw.writeLine("0     ]");
                //        this.sw.writeLine("/Prop_Build");
                //        this.sw.writeLine("<<");
                //        this.sw.writeLine(">>");
                //        this.sw.writeLine(">>");
                //        this.sw.writeLine("endobj");
                //        this.sw.writeLine("");
                //    }
                // }
                //#endregion
                //#region RenderTooltipTable
                //        private void RenderTooltipTable()
                // {
                //    if (haveTooltips == true) {
                //        for (int index = 0; index < tooltipsCounter; index++)
                //        {
                //            StiLinkObject stl = (StiLinkObject)tooltipsArray[index];
                //            //find matches hyperlink if one exists
                //            bool needHyperlink = false;
                //            StiLinkObject stlink = new StiLinkObject();
                //            for (int indexLink = 0; indexLink < linksCounter; indexLink++)
                //            {
                //                stlink = (StiLinkObject)linksArray[indexLink];
                //                if (stlink.X == stl.X &&
                //                    stlink.Y == stl.Y &&
                //                    stlink.Width == stl.Width &&
                //                    stlink.Height == stl.Height &&
                //                    stlink.Page - 1 == stl.Page) {
                //                    needHyperlink = true;
                //                    break;
                //                }
                //            }
                //            // /Type /Annot
                //            // /Subtype /Widget
                //            // /Rect [ 10.2443 718.772 84.9895 784.032 ]
                //            // /TU (It's tooltip for this text)
                //            // /F 4
                //            // /P 5 0 R
                //            // /T (Check Box1)
                //            // /FT /Btn
                //            // /Ff 65536
                //            // /H /N
                //            //// /MK <<
                //            //// /BG [ 1 ]
                //            //// /BC [ 0 ]
                //            //// >>
                //            // /AP <<
                //            //// /N 20 0 R
                //            // >>
                //            this.addXref(this.info.AcroForm.Tooltips[index].ref);
                //            this.sw.writeLine("{0} 0 obj", this.info.AcroForm.Tooltips[index].ref);
                //            this.sw.writeLine("<<");
                //            this.sw.writeLine("/Type /Annot");
                //            this.sw.writeLine("/Subtype /Widget");
                //            this.sw.writeLine("/Rect [{0} {1} {2} {3}]",
                //                this.convertToString(stl.X),
                //                this.convertToString(stl.Y),
                //                this.convertToString(stl.X + stl.Width),
                //                this.convertToString(stl.Y + stl.Height));
                //            this.storeStringLine("/TU ", stl.Link);
                //            this.sw.writeLine("/F 0");
                //            this.sw.writeLine("/P {0} 0 R", this.info.PageList[stl.Page].ref);
                //            this.storeStringLine("/T ", string.Format("Tooltip{0}", index));
                //            this.sw.writeLine("/FT /Btn");
                //            this.sw.writeLine("/Ff 65536");
                //            this.sw.writeLine("/H /N");
                //            //this.sw.writeLine("/MK <<");
                //            //this.sw.writeLine("/BG [ 1 ]");
                //            //this.sw.writeLine("/BC [ 0 ]");
                //            //this.sw.writeLine(">>");
                //            //this.sw.writeLine("/AP << /N {0} 0 R >>", xannotOffset + annotsCounter + index + 1);
                //            this.sw.writeLine("/AP <<");
                //            this.sw.writeLine(">>");
                //            //this.sw.writeLine("/N {0} 0 R", indexOffset + tooltipsCounter + index);
                //            if (needHyperlink) {
                //                #region Hyperlink info
                //                if (stlink.Link[0] == '#') {
                //                    if (stlink.DestY > -1) this.sw.writeLine("/Dest [{0} 0 R /XYZ null {1} null]", this.info.PageList[stlink.DestPage].Ref, this.convertToString(stlink.DestY));
                //                    else this.sw.writeLine("/Dest [{0} 0 R /XYZ null null null]", this.info.PageList[0].ref);
                //                }
                //                else {
                //                    this.sw.writeLine("/A <<");
                //                    this.sw.writeLine("/Type /Action");
                //                    this.sw.writeLine("/S /URI");
                //                    //this.storeStringLine("/URI ", ConvertToEscapeSequence(stlink.Link.sti.replaceAll('\\', '/')));
                //                    this.storeStringLine("/URI ", StiExportUtils.StringToUrl(this.stringReplace(stlink.Link, '\\', '/')));
                //                    this.sw.writeLine(">>");
                //                }
                //                #endregion
                //            }
                //            this.sw.writeLine(">>");
                //            this.sw.writeLine("endobj");
                //            this.sw.writeLine("");
                //        }
                //    }
                // }
                //#endregion
                //#region RenderEncodeRecord
                StiPdfExportService.prototype.renderEncodeRecord = function () {
                    if (this.encrypted) {
                        this.addXref(this.info.encode.ref);
                        this.sw.writeLine("{0} 0 obj", this.info.encode.ref);
                        this.sw.writeLine("<<");
                        this.pdfSecurity.renderEncodeRecord(this.sw);
                        this.sw.writeLine(">>");
                        this.sw.writeLine("endobj");
                        this.sw.writeLine("");
                    }
                };
                //#endregion
                StiPdfExportService.prototype.renderExtGStateRecord = function () {
                    this.addXref(this.info.extGState.ref);
                    this.sw.writeLine("{0} 0 obj", this.info.extGState.ref);
                    this.sw.writeLine("<<");
                    for (var index = 0; index < 256; index++) {
                        if (this.alphaTable[index]) {
                            var stNum = StiString.format("{0:X2}", index).toUpperCase();
                            this.sw.writeLine("/GS{0}S <</Type /ExtGState /BM /Normal /CA {1}>>", stNum, this.colorTable[index]);
                            this.sw.writeLine("/GS{0}N <</Type /ExtGState /BM /Normal /ca {1}>>", stNum, this.colorTable[index]);
                        }
                    }
                    this.sw.writeLine(">>");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                };
                // StoreImageData, WriteImageInfo
                StiPdfExportService.prototype.storeImageData = function (image, imageResolution, isImageComponent, needSmoothing) {
                    // Check resolution for Image component
                    // if (isImageComponent && ((imageResolutionMode == StiImageResolutionMode.NoMoreThan) && (imageResolution > imageResolutionMain))) {
                    //    int newWidth = (int)Math.round2(image.Width * imageResolutionMain / imageResolution);
                    //    int newHeight = (int)Math.round2(image.Height * imageResolutionMain / imageResolution);
                    //    Bitmap newBmp = new Bitmap(newWidth, newHeight);
                    //    Graphics g = Graphics.FromImage(newBmp);
                    //    if (usePdfA) g.Clear(Color.White);
                    //    g.DrawImage(image, new Rectangle(0, 0, newWidth, newHeight), 0, 0, image.Width, image.Height, GraphicsUnit.Pixel);
                    //    g.Dispose();
                    //    image = newBmp;
                    //    imageResolution = imageResolutionMain;
                    // }
                    // Remove transparency for PDF/ A mode
                    // if (isImageComponent && usePdfA && ((imageResolutionMode == StiImageResolutionMode.Auto) || ((imageResolutionMode == StiImageResolutionMode.NoMoreThan) && (imageResolution <= imageResolutionMain)))) {
                    //    int newWidth = image.Width;
                    //    int newHeight = image.Height;
                    //    Bitmap newBmp = new Bitmap(newWidth, newHeight);
                    //    Graphics g = Graphics.FromImage(newBmp);
                    //    g.Clear(Color.White);
                    //    g.DrawImage(image, new Rectangle(0, 0, newWidth, newHeight), 0, 0, newWidth, newHeight, GraphicsUnit.Pixel);
                    //    g.Dispose();
                    //    image = newBmp;
                    // }
                    // Gray colors or monochrome
                    // if (imageFormat != StiImageFormat.Color) {
                    //    Bitmap newBmp = new Bitmap(image.Width, image.Height);
                    //    Graphics g = Graphics.FromImage(newBmp);
                    //    ColorMatrix matrix = new ColorMatrix(new float[][]{
                    //        new float[]{0.3f, 0.3f, 0.3f, 0, 0},
                    //        new float[]{0.55f, 0.55f, 0.55f, 0, 0},
                    //        new float[]{0.15f, 0.15f, 0.15f, 0, 0},
                    //        new float[]{0, 0, 0, 1, 0, 0},
                    //        new float[]{0, 0, 0, 0, 1, 0},
                    //        new float[]{0, 0, 0, 0, 0, 1}});
                    //    ImageAttributes attributes = new ImageAttributes();
                    //    attributes.SetColorMatrix(matrix);
                    //    g.DrawImage(image, new Rectangle(0, 0, image.Width, image.Height), 0, 0, image.Width, image.Height, GraphicsUnit.Pixel, attributes);
                    //    g.Dispose();
                    //    //image.Dispose();
                    //    image = newBmp;
                    // }
                    // if (imageFormat == StiImageFormat.Monochrome) {
                    //    image = StiTiffHelper.MakeMonochromeImage(image, monochromeDitheringType, 128);
                    // }
                    if (image != null)
                        image.tryConvertSync(Stimulsoft.System.Drawing.Imaging.ImageFormat.Jpeg);
                    var imageIndex = this.imageCache.addImageInt(image);
                    var pd = new StiImageData();
                    if (image != null && image.bytes != null) {
                        pd.Width = image.width;
                        pd.Height = image.height;
                    }
                    else {
                        pd.Width = 1;
                        pd.Height = 1;
                    }
                    pd.Name = StiString.format("Image{0}", imageIndex);
                    pd.ImageFormat = this.imageFormat;
                    // if (image.PixelFormat == PixelFormat.Format1bppIndexed) {
                    //    pd.ImageFormat = StiImageFormat.Monochrome;
                    // }
                    this.imageList.add(pd);
                    this.imageCacheIndexToList.set(imageIndex, pd);
                    if (needSmoothing) {
                        this.imageInterpolationTable.set(imageIndex, true);
                    }
                    return imageResolution;
                };
                // internal void StoreImageDataForGeom(StiImage image)
                // {
                //    float rsImageResolution = image.ImageToDraw.HorizontalResolution / 100;
                //    if (imageResolutionMode == StiImageResolutionMode.NoMoreThan) {
                //        if (image.Stretch) {
                //            rsImageResolution = (float)(image.ImageToDraw.Width / report.Unit.ConvertToHInches(image.Width));
                //        }
                //        else {
                //            rsImageResolution = (float)(1 / image.MultipleFactor);
                //        }
                //    }
                //    rsImageResolution = StoreImageData(image.ImageToDraw, rsImageResolution, true, image.Smoothing);
                //    imageInfoList[imageInfoCounter] = rsImageResolution;
                // }
                StiPdfExportService.prototype.writeImageInfo = function (pp, imageResolution) {
                    var pd = this.imageList[this.imagesCurrent];
                    this.imagesCurrent++;
                    var view = pp.Component.sti.as(StiImage);
                    if ((this.imageResolutionMode != Export.StiImageResolutionMode.Exactly) && (view != null) && !view.margins.isEmpty) {
                        var marginsLeft = this.hiToTwips * view.margins.left;
                        var marginsRight = this.hiToTwips * view.margins.right;
                        var marginsTop = this.hiToTwips * view.margins.top;
                        var marginsBottom = this.hiToTwips * view.margins.bottom;
                        if (marginsLeft != 0) {
                            pp.X += marginsLeft;
                            pp.Width -= marginsLeft;
                        }
                        if (marginsBottom != 0) {
                            pp.Y += marginsBottom;
                            pp.Height -= marginsBottom;
                        }
                        if (marginsRight != 0)
                            pp.Width -= marginsRight;
                        if (marginsTop != 0)
                            pp.Height -= marginsTop;
                    }
                    var pdWidth = pd.Width;
                    var pdHeight = pd.Height;
                    if (view.imageRotation == StiImageRotation.Rotate90CCW || view.imageRotation == StiImageRotation.Rotate90CW) {
                        pdWidth = pd.Height;
                        pdHeight = pd.Width;
                    }
                    // values for fixed resolution
                    var cx = pp.X;
                    var cy = pp.Y;
                    var cw = this.hiToTwips * (pdWidth - 1) / imageResolution;
                    var ch = this.hiToTwips * (pdHeight - 1) / imageResolution;
                    var needClip = false;
                    if ((this.imageResolutionMode != Export.StiImageResolutionMode.Exactly) && (view != null) && (view.imageToDraw != null)) {
                        var imageForPaint = view.imageToDraw;
                        var rect = view.getPaintRectangle(true, false);
                        rect = view.convertImageMargins(rect, false);
                        var destRect = new RectangleD(0, 0, rect.width, rect.height);
                        if (!view.stretch) {
                            var imageWidth = pdWidth * view.multipleFactor;
                            var imageHeight = pdHeight * view.multipleFactor;
                            if (imageForPaint == null || imageForPaint.bytes == null) {
                                imageWidth = 1;
                                imageHeight = 1;
                            }
                            destRect.width = imageWidth;
                            destRect.height = imageHeight;
                            switch (view.horAlignment) {
                                case StiHorAlignment.Center:
                                    destRect.x = (rect.width - imageWidth) / 2;
                                    break;
                                case StiHorAlignment.Right:
                                    destRect.x = rect.width - imageWidth;
                                    break;
                            }
                            switch (view.vertAlignment) {
                                case StiVertAlignment.Center:
                                    destRect.y = (rect.height - imageHeight) / 2;
                                    break;
                                case StiVertAlignment.Top:
                                    destRect.y = rect.height - imageHeight;
                                    break;
                            }
                            cx += destRect.x * this.hiToTwips;
                            cy += destRect.y * this.hiToTwips;
                            cw = destRect.width * this.hiToTwips;
                            ch = destRect.height * this.hiToTwips;
                            needClip = true;
                        }
                        else {
                            var imageWidth = pdWidth;
                            var imageHeight = pdHeight;
                            if (imageForPaint == null) {
                                imageWidth = 1;
                                imageHeight = 1;
                            }
                            if (view.aspectRatio) {
                                var xRatio = destRect.width / imageWidth;
                                var yRatio = destRect.height / imageHeight;
                                if (xRatio > yRatio)
                                    destRect.width = imageWidth * yRatio;
                                else
                                    destRect.height = imageHeight * xRatio;
                                switch (view.vertAlignment) {
                                    case StiVertAlignment.Center:
                                        destRect.y = (rect.height - destRect.height) / 2;
                                        break;
                                    case StiVertAlignment.Top:
                                        destRect.y = rect.height - destRect.height;
                                        break;
                                }
                                switch (view.horAlignment) {
                                    case StiHorAlignment.Center:
                                        destRect.x = (rect.width - destRect.width) / 2;
                                        break;
                                    case StiHorAlignment.Right:
                                        destRect.x = rect.width - destRect.width;
                                        break;
                                }
                                cx += destRect.x * this.hiToTwips;
                                cy += destRect.y * this.hiToTwips;
                                cw = destRect.width * this.hiToTwips;
                                ch = destRect.height * this.hiToTwips;
                            }
                            else {
                                cw = pp.Width;
                                ch = pp.Height;
                            }
                        }
                        // if (view.isCachedImage) imageForPaint.dispose();  // !!! пока не надо, т.к. картинки хранятся не в реальном кэше, а в хэш-таблице
                    }
                    this.pageStream.writeLine("q");
                    this.pushColorToStack();
                    this.setNonStrokeColor(Color.black);
                    if (needClip) {
                        this.pageStream.writeLine("{0} {1} {2} {3} re W n", this.convertToString(pp.X), this.convertToString(pp.Y), this.convertToString(pp.Width), this.convertToString(pp.Height));
                    }
                    if (view.imageRotation == StiImageRotation.None) {
                        this.pageStream.writeLine("{0} 0 0 {1} {2} {3} cm", this.convertToString(cw), this.convertToString(ch), this.convertToString(cx), this.convertToString(cy));
                    }
                    else {
                        this.pageStream.writeLine("1 0 0 1 {0} {1} cm", this.convertToString(cx + cw / 2), this.convertToString(cy + ch / 2));
                        if (view.imageRotation == StiImageRotation.Rotate90CCW) {
                            this.pageStream.writeLine("0 1 -1 0 0 0 cm");
                        }
                        if (view.imageRotation == StiImageRotation.Rotate90CW) {
                            this.pageStream.writeLine("0 -1 1 0 0 0 cm");
                        }
                        if (view.imageRotation == StiImageRotation.Rotate180) {
                            this.pageStream.writeLine("-1 0 0 -1 0 0 cm");
                        }
                        if (view.imageRotation == StiImageRotation.FlipHorizontal) {
                            this.pageStream.writeLine("-1 0 0 1 0 0 cm");
                        }
                        if (view.imageRotation == StiImageRotation.FlipVertical) {
                            this.pageStream.writeLine("1 0 0 -1 0 0 cm");
                        }
                        if (view.imageRotation == StiImageRotation.Rotate90CCW || view.imageRotation == StiImageRotation.Rotate90CW) {
                            this.pageStream.writeLine("{0} 0 0 {1} {2} {3} cm", this.convertToString(ch), this.convertToString(cw), this.convertToString(-ch / 2), this.convertToString(-cw / 2));
                        }
                        else {
                            this.pageStream.writeLine("{0} 0 0 {1} {2} {3} cm", this.convertToString(cw), this.convertToString(ch), this.convertToString(-cw / 2), this.convertToString(-ch / 2));
                        }
                    }
                    this.pageStream.writeLine("/{0} Do", pd.Name);
                    this.pageStream.writeLine("Q");
                    this.popColorFromStack();
                };
                StiPdfExportService.prototype.renderImage = function (pp, imageResolution) {
                    if (this.imageInfoList.containsKey(this.imageInfoCounter)) {
                        var rsImageResolution = this.imageInfoList.get(this.imageInfoCounter);
                        this.writeImageInfo(pp, rsImageResolution);
                    }
                    else {
                        var exportImage = pp.Component.sti.as(IStiExportImageExtended);
                        if (exportImage != null && pp.Component.isExportAsImage(Report.StiExportFormat.Pdf)) {
                            var rsImageResolution = imageResolution;
                            var REFrsImageResolution = { ref: rsImageResolution };
                            var image = exportImage.getImage(REFrsImageResolution, Report.StiExportFormat.Pdf);
                            rsImageResolution = REFrsImageResolution.ref;
                            if ((image != null) && (image.bytes != null)) {
                                this.writeImageInfo(pp, rsImageResolution);
                            }
                        }
                    }
                };
                //#region Render Watermark
                StiPdfExportService.prototype.renderWatermark = function (page, behind, pageWidth, pageHeight, imageResolution) {
                    var watermark = page.watermark;
                    if ((watermark != null) && (watermark.enabled)) {
                        //#region watermark image
                        if (watermark.image != null && watermark.showImageBehind == behind) {
                            var pd = this.imageList[this.imagesCurrent];
                            var imageWidth = pd.Width * this.hiToTwips * watermark.imageMultipleFactor;
                            var imageHeight = pd.Height * this.hiToTwips * watermark.imageMultipleFactor;
                            var imageX = 0;
                            var imageY = 0;
                            var dupX = 1;
                            var dupY = 1;
                            var align = watermark.imageAlignment;
                            var isImageTiling = watermark.imageTiling;
                            if (watermark.imageStretch) {
                                var aspectRatio = imageHeight / imageWidth;
                                imageWidth = pageWidth;
                                imageHeight = pageHeight;
                                isImageTiling = false;
                                if (watermark.aspectRatio) {
                                    if (pageHeight / pageWidth > aspectRatio) {
                                        imageHeight = imageWidth * aspectRatio;
                                    }
                                    else {
                                        imageWidth = imageHeight / aspectRatio;
                                    }
                                }
                            }
                            if ((watermark.imageStretch) || (watermark.imageMultipleFactor > 1)) {
                                this.imageInterpolationTable.set(this.imageCache.imageIndex[this.imagesCurrent], true);
                            }
                            if (isImageTiling) {
                                align = Stimulsoft.System.Drawing.ContentAlignment.TopLeft;
                                dupX = Math.round2(pageWidth / imageWidth) + 1;
                                dupY = Math.round2(pageHeight / imageHeight) + 1;
                            }
                            switch (align) {
                                case Stimulsoft.System.Drawing.ContentAlignment.TopCenter:
                                case Stimulsoft.System.Drawing.ContentAlignment.MiddleCenter:
                                case Stimulsoft.System.Drawing.ContentAlignment.BottomCenter:
                                    imageX = (pageWidth - imageWidth) / 2;
                                    break;
                                case Stimulsoft.System.Drawing.ContentAlignment.TopRight:
                                case Stimulsoft.System.Drawing.ContentAlignment.MiddleRight:
                                case Stimulsoft.System.Drawing.ContentAlignment.BottomRight:
                                    imageX = pageWidth - imageWidth;
                                    break;
                            }
                            switch (align) {
                                case Stimulsoft.System.Drawing.ContentAlignment.TopLeft:
                                case Stimulsoft.System.Drawing.ContentAlignment.TopCenter:
                                case Stimulsoft.System.Drawing.ContentAlignment.TopRight:
                                    imageY = pageHeight - imageHeight;
                                    break;
                                case Stimulsoft.System.Drawing.ContentAlignment.MiddleLeft:
                                case Stimulsoft.System.Drawing.ContentAlignment.MiddleCenter:
                                case Stimulsoft.System.Drawing.ContentAlignment.MiddleRight:
                                    imageY = (pageHeight - imageHeight) / 2;
                                    break;
                            }
                            this.setNonStrokeColor(Color.fromArgb(255 - watermark.imageTransparency, Color.black));
                            for (var indexY = 0; indexY < dupY; indexY++) {
                                for (var indexX = 0; indexX < dupX; indexX++) {
                                    this.pageStream.writeLine("q");
                                    this.pushColorToStack();
                                    this.pageStream.writeLine("{0} 0 0 {1} {2} {3} cm", this.convertToString(imageWidth), this.convertToString(imageHeight), this.convertToString(imageX + imageWidth * indexX), this.convertToString(imageY - imageHeight * indexY));
                                    this.pageStream.writeLine("/{0} Do", pd.Name);
                                    this.pageStream.writeLine("Q");
                                    this.popColorFromStack();
                                }
                            }
                            this.imagesCurrent++;
                        }
                        //#endregion
                        //#region watermark text
                        if ((!StiString.isNullOrEmpty(watermark.text)) && (watermark.showBehind == behind)) {
                            var pp = new StiPdfData(this);
                            pp.X = 0;
                            pp.Y = 0;
                            pp.Width = pageWidth;
                            pp.Height = pageHeight;
                            var stt = new StiText(new RectangleD(pp.X, pp.Y, pp.Width, pp.Height));
                            stt.text = watermark.text;
                            stt.textBrush = watermark.textBrush;
                            stt.font = watermark.font;
                            stt.textOptions = new Stimulsoft.Base.Drawing.StiTextOptions();
                            stt.textOptions.angle = watermark.angle;
                            stt.horAlignment = Stimulsoft.Base.Drawing.StiTextHorAlignment.Center;
                            stt.vertAlignment = StiVertAlignment.Center;
                            stt.page = page;
                            stt.textQuality = Stimulsoft.Report.Components.StiTextQuality.Standard;
                            pp.Component = stt;
                            Export.StiPdfRenderText.renderTextFont(pp);
                            Export.StiPdfRenderText.renderText(pp);
                        }
                        //#endregion
                    }
                };
                //#endregion
                // Store brushes data
                StiPdfExportService.prototype.storeShadingData1 = function (brush, pageNumber) {
                    if (brush != null) {
                        if (brush.sti.is(StiGradientBrush)) {
                            var gbr = brush.sti.as(StiGradientBrush);
                            var ssd = new StiShadingData();
                            ssd.Angle = gbr.angle;
                            ssd.Color1 = gbr.startColor;
                            ssd.Color2 = gbr.endColor;
                            ssd.Page = pageNumber;
                            this.shadingArray.add(ssd);
                        }
                        if (brush.sti.is(StiGlareBrush)) {
                            var gbr = brush.sti.as(StiGlareBrush);
                            var ssd = new StiShadingData();
                            ssd.Angle = gbr.angle;
                            ssd.Color1 = gbr.startColor;
                            ssd.Color2 = gbr.endColor;
                            ssd.IsGlare = true;
                            ssd.Page = pageNumber;
                            this.shadingArray.add(ssd);
                        }
                    }
                };
                StiPdfExportService.prototype.storeShadingData2 = function (x, y, width, height, brush) {
                    if ((brush != null) && (brush.sti.is(StiGradientBrush) || brush.sti.is(StiGlareBrush))) {
                        var ssd = this.shadingArray[this.shadingCurrent];
                        ssd.X = x;
                        ssd.Y = y;
                        ssd.Width = width;
                        ssd.Height = height;
                        this.shadingArray[this.shadingCurrent] = ssd;
                        this.shadingCurrent++;
                    }
                    return this.shadingCurrent;
                };
                StiPdfExportService.prototype.storeHatchData = function (brush) {
                    if (brush != null) {
                        if (brush.sti.is(StiHatchBrush)) {
                            this.getHatchNumber(brush.sti.as(StiHatchBrush));
                        }
                        if (brush.sti.is(StiGlassBrush)) {
                            var glass = brush.sti.as(StiGlassBrush);
                            if (glass.drawHatch) {
                                // this.getHatchNumber(glass.getTopBrush() as HatchBrush);
                                // this.getHatchNumber(glass.getBottomBrush() as HatchBrush);
                            }
                        }
                    }
                };
                StiPdfExportService.prototype.renderMetadata = function (report) {
                    // Make memory stream
                    var mainStream = new MemoryStream();
                    var stXpacket = "<?xpacket begin=\"\xEF\xBB\xBF\" id=\"W5M0MpCehiHzreSzNTczkc9d\"?>\r\n";
                    mainStream.writeString(stXpacket);
                    // Make XML data
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Stimulsoft.System.Text.Encoding.UTF8, ms);
                    writer.formatting = Stimulsoft.System.Xml.Formatting.Indented;
                    writer.writeStartElement("x:xmpmeta");
                    writer.writeAttributeString("xmlns:x", "adobe:ns:meta/");
                    writer.writeAttributeString("x:xmptk", "Adobe XMP Core 4.0-c316 44.253921, Sun Oct 01 2006 17:14:39");
                    writer.writeStartElement("rdf:RDF");
                    writer.writeAttributeString("xmlns:rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
                    writer.writeStartElement("rdf:Description");
                    writer.writeAttributeString("rdf:about", "");
                    writer.writeAttributeString("xmlns:xap", "http://ns.adobe.com/xap/1.0/");
                    writer.writeElementString("xap:ModifyDate", this.currentDateTimeMeta);
                    writer.writeElementString("xap:CreateDate", this.currentDateTimeMeta);
                    writer.writeElementString("xap:MetadataDate", this.currentDateTimeMeta);
                    writer.writeElementString("xap:CreatorTool", StiOptions.Export.Pdf.creatorString);
                    writer.writeFullEndElement(); // rdf:Description
                    // Report info
                    writer.writeStartElement("rdf:Description");
                    writer.writeAttributeString("rdf:about", "");
                    writer.writeAttributeString("xmlns:dc", "http://purl.org/dc/elements/1.1/");
                    writer.writeElementString("dc:format", "application/pdf");
                    writer.writeStartElement("dc:title");
                    writer.writeStartElement("rdf:Alt");
                    if (!StiString.isNullOrEmpty(report.reportName)) {
                        writer.writeStartElement("rdf:li");
                        writer.writeAttributeString("xml:lang", "x-default");
                        writer.writeString(report.reportName);
                        writer.writeFullEndElement(); // rdf:li
                    }
                    writer.writeEndElement(); // rdf:Alt
                    writer.writeFullEndElement(); // dc:title
                    writer.writeStartElement("dc:description");
                    writer.writeStartElement("rdf:Alt");
                    if (!StiString.isNullOrEmpty(report.reportAlias)) {
                        writer.writeStartElement("rdf:li");
                        writer.writeAttributeString("xml:lang", "x-default");
                        writer.writeString(report.reportAlias);
                        writer.writeFullEndElement(); // rdf:li
                    }
                    writer.writeEndElement(); // rdf:Alt
                    writer.writeFullEndElement(); // dc:description
                    writer.writeStartElement("dc:creator");
                    writer.writeStartElement("rdf:Seq");
                    if (!StiString.isNullOrEmpty(report.reportAuthor)) {
                        writer.writeStartElement("rdf:li");
                        writer.writeAttributeString("xml:lang", "x-default");
                        writer.writeString(report.reportAuthor);
                        writer.writeFullEndElement(); // rdf:li
                    }
                    writer.writeEndElement(); // rdf:Seq
                    writer.writeFullEndElement(); // dc:creator
                    writer.writeStartElement("dc:subject");
                    writer.writeStartElement("rdf:Bag");
                    if (!StiString.isNullOrEmpty(this.keywords)) {
                        var words = this.keywords.split(";");
                        for (var _i = 0, words_2 = words; _i < words_2.length; _i++) {
                            var word = words_2[_i];
                            writer.writeStartElement("rdf:li");
                            writer.writeString(word.trim());
                            writer.writeFullEndElement(); // rdf:li
                        }
                    }
                    writer.writeEndElement(); // rdf:Bag
                    writer.writeFullEndElement(); // dc:subject
                    writer.writeFullEndElement(); // rdf:Description
                    writer.writeStartElement("rdf:Description");
                    writer.writeAttributeString("rdf:about", "");
                    writer.writeAttributeString("xmlns:xapMM", "http://ns.adobe.com/xap/1.0/mm/");
                    writer.writeElementString("xapMM:DocumentID", this.IDValueStringMeta);
                    writer.writeElementString("xapMM:InstanceID", this.IDValueStringMeta);
                    writer.writeFullEndElement(); // rdf:Description
                    writer.writeStartElement("rdf:Description");
                    writer.writeAttributeString("rdf:about", "");
                    writer.writeAttributeString("xmlns:pdf", "http://ns.adobe.com/pdf/1.3/");
                    writer.writeAttributeString("xmlns:pdfx", "http://ns.adobe.com/pdf/1.3/");
                    writer.writeElementString("pdf:Producer", this.producerName);
                    writer.writeElementString("pdf:Keywords", this.keywords);
                    // for (let meta of report.MetaTags)
                    // {
                    //    if (meta.Name.sti.startsWith("pdf:")) {
                    //        writer.writeElementString("pdfx:" + meta.Name.substr(4), meta.Tag);
                    //    }
                    // }
                    writer.writeFullEndElement(); // rdf:Description
                    if (this.usePdfA) {
                        writer.writeStartElement("rdf:Description");
                        writer.writeAttributeString("rdf:about", "");
                        writer.writeAttributeString("xmlns:pdfaid", "http://www.aiim.org/pdfa/ns/id/");
                        var pdfaidPart = "1";
                        switch (this.pdfComplianceMode) {
                            case Export.StiPdfComplianceMode.A1:
                                pdfaidPart = "1";
                                break;
                            case Export.StiPdfComplianceMode.A2:
                                pdfaidPart = "2";
                                break;
                            case Export.StiPdfComplianceMode.A3:
                                pdfaidPart = "3";
                                break;
                        }
                        writer.writeElementString("pdfaid:part", pdfaidPart);
                        writer.writeElementString("pdfaid:conformance", "A");
                        writer.writeFullEndElement(); // rdf:Description
                    }
                    writer.writeFullEndElement(); // rdf:RD
                    writer.writeFullEndElement(); // x:xmpmeta
                    writer.writeString("                              \r\n");
                    writer.writeString("                              \r\n");
                    writer.writeString("                              \r\n");
                    writer.writeString("                              \r\n");
                    writer.writeString("                              \r\n");
                    var tempBuffer = ms.toArray();
                    writer.close();
                    ms.close();
                    // mainStream.write(tempBuffer, 3, tempBuffer.length - 3);
                    mainStream.write(tempBuffer, 0, tempBuffer.length);
                    mainStream.writeString("<?xpacket end=\"w\"?>");
                    this.addXref(this.info.metadata.ref);
                    this.sw.writeLine("{0} 0 obj", this.info.metadata.ref);
                    this.sw.writeLine("<<");
                    this.sw.writeLine("/Type /Metadata");
                    this.sw.writeLine("/Subtype /XML");
                    this.storeMemoryStream2(mainStream, "/Length {0}");
                    this.sw.writeLine("");
                    this.sw.writeLine("endstream");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                };
                StiPdfExportService.prototype.renderColorSpace = function () {
                    this.addXref(this.info.destOutputProfile.ref);
                    this.sw.writeLine("{0} 0 obj", this.info.destOutputProfile.ref);
                    this.sw.writeLine("<<");
                    this.sw.writeLine("/N 3");
                    var tmpStream = null;
                    var stColorSpace = null;
                    if (this.compressed == true) {
                        tmpStream = Export.StiExportUtils.makePdfDeflateStream(Export.StiPdfResources.sRGBprofile);
                        stColorSpace = "/Length {0} /Filter [/FlateDecode] /Length1 " + Export.StiPdfResources.sRGBprofile.length.toString();
                        this.storeMemoryStream2(tmpStream, stColorSpace);
                    }
                    else {
                        tmpStream = new MemoryStream();
                        tmpStream.write(Export.StiPdfResources.sRGBprofile, 0, Export.StiPdfResources.sRGBprofile.length);
                        stColorSpace = "/Length {0}";
                        this.storeMemoryStream2(tmpStream, stColorSpace);
                    }
                    this.sw.writeLine("");
                    this.sw.writeLine("endstream");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                    this.addXref(this.info.outputIntents.ref);
                    this.sw.writeLine("{0} 0 obj", this.info.outputIntents.ref);
                    this.sw.writeLine("[<<");
                    this.storeStringLine("/Info", "sRGB IEC61966-2.1");
                    this.storeStringLine("/OutputConditionIdentifier", "Custom");
                    this.storeStringLine("/OutputCondition", "");
                    this.storeStringLine("/RegistryName", "");
                    this.sw.writeLine("/S /GTS_PDFA1");
                    this.sw.writeLine("/DestOutputProfile {0} 0 R", this.info.destOutputProfile.ref);
                    this.sw.writeLine("/Type /OutputIntent");
                    this.sw.writeLine(">>]");
                    this.sw.writeLine("endobj");
                    this.sw.writeLine("");
                };
                StiPdfExportService.prototype.renderAutoPrint = function () {
                    if (this.autoPrint != Export.StiPdfAutoPrintMode.None) {
                        this.addXref(this.info.embeddedJS.ref);
                        this.sw.writeLine("{0} 0 obj", this.info.embeddedJS.ref);
                        this.sw.writeLine("<<");
                        this.sw.writeLine("/Names [(EmbeddedJS) {0} 0 R]", this.info.embeddedJS.content.ref);
                        this.sw.writeLine(">>");
                        this.sw.writeLine("endobj");
                        this.sw.writeLine("");
                        this.addXref(this.info.embeddedJS.content.ref);
                        this.sw.writeLine("{0} 0 obj", this.info.embeddedJS.content.ref);
                        this.sw.writeLine("<<");
                        this.sw.writeLine("/S /JavaScript");
                        this.sw.writeLine("/JS (print\\({0}\\);)", this.autoPrint == Export.StiPdfAutoPrintMode.Dialog ? "true" : "false");
                        this.sw.writeLine(">>");
                        this.sw.writeLine("endobj");
                        this.sw.writeLine("");
                    }
                };
                //#region StiBookmarkTreeNode
                // private class StiBookmarkTreeNode {
                //    int Parent;
                //    int First;
                //    int Last;
                //    int Prev;
                //    int Next;
                //    int Count;
                //    int Page;
                //    double Y;
                //    string Title;
                //    string Guid;
                //    bool Used;
                // }
                //#endregion
                //#region AddBookmarkNode
                // 		private void AddBookmarkNode(StiBookmark bkm, int parentNode)
                // {
                //    StiBookmarkTreeNode tn = new StiBookmarkTreeNode();
                //    tn.Parent = -1;
                //    tn.First = -1;
                //    tn.Last = -1;
                //    tn.Prev = -1;
                //    tn.Next = -1;
                //    tn.Count = -1;
                //    tn.Page = -1;
                //    tn.Y = -1;
                //    tn.Title = string.Empty;
                //    tn.Guid = string.Empty;
                //    tn.Used = (parentNode == -1 ? true : false);
                //    bookmarksTree.Add(tn);
                //    int currentNode = bookmarksTree.Count - 1;
                //    tn.Parent = parentNode;
                //    tn.Title = bkm.Text;
                //    tn.Guid = bkm.ComponentGuid;
                //    if (bkm.Bookmarks.Count == 0) {
                //        tn.Count = 0;
                //    }
                //    else {
                //        int prevNode = -1;
                //        for (int tempCount = 0; tempCount <= bkm.Bookmarks.Count - 1; tempCount++)
                //        {
                //            int memNode = bookmarksTree.Count;
                //            StiBookmark sbm = bkm.Bookmarks[tempCount];
                //            AddBookmarkNode(sbm, currentNode);
                //            StiBookmarkTreeNode tempBM = (StiBookmarkTreeNode)bookmarksTree[memNode];
                //            if (tempCount < bkm.Bookmarks.Count - 1) {
                //                tempBM.Next = bookmarksTree.Count;
                //            }
                //            if (tempCount > 0) {
                //                tempBM.Prev = prevNode;
                //            }
                //            bookmarksTree[memNode] = tempBM;
                //            prevNode = memNode;
                //        }
                //        tn.First = currentNode + 1;
                //        tn.Last = bookmarksTree.Count - 1;
                //        tn.Count = bookmarksTree.Count - currentNode - 1;
                //    }
                //    bookmarksTree[currentNode] = tn;
                // }
                //#endregion
                //#region MakeBookmarkFromTree
                // 		private void MakeBookmarkFromTree(StiBookmark bookmark, StiBookmarkTreeNode treeNode)
                // {
                //    bookmark.Text = treeNode.Title;
                //    bookmark.Bookmarks = new StiBookmarksCollection();
                //    if (treeNode.Count > 0) {
                //        int nodePos = treeNode.First;
                //        while (nodePos != -1) {
                //            StiBookmarkTreeNode tnChild = (StiBookmarkTreeNode)bookmarksTree[nodePos];
                //            if (tnChild.Used) {
                //                StiBookmark childBookmark = new StiBookmark();
                //                bookmark.Bookmarks.Add(childBookmark);
                //                MakeBookmarkFromTree(childBookmark, tnChild);
                //            }
                //            nodePos = tnChild.Next;
                //        }
                //    }
                // }
                //#endregion
                //#region StiLinkObject
                // 		private struct StiLinkObject
                // {
                // 			double X;
                // 			double Y;
                // 			double Width;
                // 			double Height;
                // 			int Page;
                // 			int DestPage;
                // 			double DestY;
                // 			string Link;
                // }
                //#endregion
                StiPdfExportService.prototype.exportPdf = function (report, stream, settings) {
                    try {
                        // StiExportUtils.DisableFontSmoothing();
                        this.exportPdf1(report, stream, settings);
                    }
                    finally {
                        // StiExportUtils.EnableFontSmoothing(report);
                    }
                };
                StiPdfExportService.prototype.exportPdf1 = function (report, stream, settings) {
                    // Read settings
                    if (settings == null)
                        throw new Error(("The 'settings' argument cannot be equal in null."));
                    this.report = report;
                    var pageRange = settings.pageRange;
                    var imageResolution = settings.imageResolution;
                    this.imageResolutionMode = settings.imageResolutionMode;
                    this.imageQuality = settings.imageQuality;
                    this.embeddedFonts = settings.embeddedFonts;
                    this.standardPdfFonts = !!settings.standardPdfFonts;
                    this.compressed = !!settings.compressed;
                    this.useUnicodeMode = settings.useUnicode;
                    // this.exportRtfTextAsImage = settings.ExportRtfTextAsImage;
                    var passwordInputUser = settings.passwordInputUser;
                    var passwordInputOwner = settings.passwordInputOwner;
                    var userAccessPrivileges = settings.userAccessPrivileges;
                    this.keyLength = settings.keyLength;
                    this.pdfComplianceMode = settings.pdfComplianceMode;
                    // this.imageFormat = settings.ImageFormat;
                    // this.monochromeDitheringType = settings.DitheringType;
                    this.autoPrint = settings.autoPrintMode;
                    // let StiPdfImageCompressionMethod imageCompressionMethod = settings.ImageCompressionMethod;
                    this.allowEditable = settings.allowEditable;
                    this.creatorName = StiOptions.Export.Pdf.creatorString;
                    this.keywords = StiOptions.Export.Pdf.keywordsString;
                    if (!StiString.isNullOrEmpty(settings.creatorString)) {
                        this.creatorName = settings.creatorString;
                    }
                    if (!StiString.isNullOrEmpty(settings.keywordsString)) {
                        this.keywords = settings.keywordsString;
                    }
                    if (StiString.isNullOrEmpty(this.creatorName)) {
                        this.creatorName = this.producerName;
                    }
                    //#endregion
                    // if (useZUGFeRD) this.pdfComplianceMode = StiPdfComplianceMode.A3;
                    this.usePdfA = this.pdfComplianceMode != Export.StiPdfComplianceMode.None;
                    this.compressed = true;
                    this.compressedFonts = true;
                    if (this.usePdfA) {
                        this.standardPdfFonts = false;
                        this.embeddedFonts = true;
                        this.useUnicodeMode = true;
                    }
                    var deleteEmptyBookmarks = (pageRange.rangeType != Report.StiRangeType.All);
                    //    this.reduceFontSize = StiOptions.Export.Pdf.ReduceFontFileSize;
                    var useImageTransparency = !this.usePdfA;
                    //    if (StiOptions.Export.Pdf.AllowEditablePdf)
                    //    {
                    //        allowEditable = StiPdfAllowEditable.Yes;
                    //    }
                    if (this.embeddedFonts)
                        this.standardPdfFonts = false;
                    if (this.imageQuality < 0)
                        this.imageQuality = 0;
                    if (this.imageQuality > 1)
                        this.imageQuality = 1;
                    if (this.useUnicodeMode)
                        this.standardPdfFonts = false;
                    if (imageResolution < 10)
                        imageResolution = 10;
                    imageResolution = imageResolution / 100;
                    this.imageResolutionMain = imageResolution;
                    //    if (imageFormat == StiImageFormat.Monochrome) imageCompressionMethod = StiPdfImageCompressionMethod.Flate;
                    //    this.imageCompressionMethod = imageCompressionMethod;
                    // Initialization
                    this.bidi = new Export.StiBidirectionalConvert(true);
                    this.pdfFont = new Export.PdfFonts();
                    this.pdfFont.standardPdfFonts = this.standardPdfFonts;
                    this.pdfFont.useUnicode = this.useUnicodeMode;
                    this.fontGlyphsReduceNotNeed = null;
                    // this.precision_digits = StiOptions.Export.Pdf.DefaultCoordinatesPrecision;
                    //    //prepare procedure this.convertToString()
                    //    currentCulture = Stimulsoft.System.Globalization.CultureInfo.CurrentCulture;
                    //    currentNumberFormat = (Stimulsoft.System.Globalization.NumberFormatInfo)currentCulture.NumberFormat.Clone();
                    //    currentNumberFormat.NumberDecimalSeparator = ".";
                    // prepare color convert table
                    for (var indexColor = 0; indexColor <= 255; indexColor++) {
                        var doubleColor = Math.round2(indexColor / 255, 3);
                        var stringColor = doubleColor.toString().sti.replaceAll(",", Stimulsoft.System.Globalization.CultureInfo.currentCulture.numberFormat.numberDecimalSeparator);
                        this.colorTable[indexColor] = stringColor;
                        this.alphaTable[indexColor] = false;
                    }
                    this.lastColorStrokeA = 0xFF;
                    this.lastColorNonStrokeA = 0xFF;
                    this.colorStack = new Array();
                    this.imageList = new Array();
                    switch (this.imageCompressionMethod) {
                        case Export.StiPdfImageCompressionMethod.Flate:
                            this.imageCache = new Report.StiImageCache(true, true, Report.ImageFormat.MemoryBmp, this.imageQuality, useImageTransparency);
                            break;
                        default:
                            this.imageCache = new Report.StiImageCache(true, true, Report.ImageFormat.Jpeg, this.imageQuality, useImageTransparency);
                            break;
                    }
                    this.imageInterpolationTable = new Hashtable();
                    this.imageCacheIndexToList = new Hashtable();
                    this.imageInfoList = new Hashtable();
                    this.imageInfoCounter = 0;
                    this.pdfFont.fontList = new Array();
                    this.xref = new Array();
                    // this.bookmarksTree = new ArrayList();
                    this.haveBookmarks = false;
                    // this.linksArray = new ArrayList();
                    this.annotsArray = new Array();
                    this.annots2Array = new Array();
                    this.unsignedSignaturesArray = new Array();
                    this.shadingArray = new Array();
                    this.hatchArray = new Array();
                    // this.tooltipsArray = new List<StiLinkObject>();
                    this.sw = stream; // StreamWriter(stream, Encoding.GetEncoding(1252));
                    //    //		Stimulsoft.System.Text.Encoder enc;
                    //    enc = Stimulsoft.System.Text.Encoding.GetEncoding(1252).GetEncoder();
                    // init all counters
                    this.fontsCounter = 0;
                    this.bookmarksCounter = 0;
                    this.linksCounter = 0;
                    this.annotsCounter = 0;
                    this.annots2Counter = 0;
                    this.tooltipsCounter = 0;
                    // prepare codepage1252 info
                    for (var index = 0; index < 256; index++) {
                        this.CodePage1252[index] = index;
                    }
                    for (var index = 0; index < 32; index++) {
                        this.CodePage1252[0x80 + index] = this.CodePage1252part80AF[index];
                    }
                    this.fontGlyphsReduceNotNeed = Array.create(Boolean, 256);
                    //    mfRender = new Stimulsoft.Report.Export.Tools.StiPdfMetafileRender(this, useUnicodeMode);
                    // Make ID string
                    var dt = DateTime.now;
                    var tempDT = dt.toString("yyyyMMddHHmmsszzz");
                    this.currentDateTime = tempDT.substr(0, 17) + "'" + tempDT.substr(18, 2) + "'";
                    this.currentDateTimeMeta = dt.toString("yyyy-MM-ddTHH:mm:sszzz");
                    var IDString = dt.toString("yyyyMMddHHmmssffff");
                    IDString += this.producerName;
                    IDString += this.creatorName;
                    IDString += report.reportAuthor;
                    IDString += report.reportAlias;
                    IDString += report.reportName;
                    var forHash = "";
                    for (var index = 0; index < IDString.length; index++) {
                        forHash += String.fromCharCode(IDString.charCodeAt(index) & 0xff);
                    }
                    this.IDValue = Stimulsoft.Base.StiMD5Helper.MD5(forHash, false);
                    var tempSB = new StringBuilder();
                    for (var index = 0; index < this.IDValue.length; index++) {
                        tempSB.append(Export.StiExportUtils.toHex(this.IDValue[index]));
                    }
                    this.IDValueString = tempSB.toString();
                    this.IDValueStringMeta = StiString.format("uuid:{0}-{1}-{2}-{3}-{4}", this.IDValueString.substring(0, 8), this.IDValueString.substring(8, 4), this.IDValueString.substring(12, 4), this.IDValueString.substring(16, 4), this.IDValueString.substring(20, 12)).toLowerCase();
                    this.pdfSecurity = new Export.StiPdfSecurity(this);
                    if (!this.usePdfA) {
                        this.encrypted = this.pdfSecurity.computingCryptoValues(userAccessPrivileges, passwordInputOwner, passwordInputUser, this.keyLength, this.IDValue);
                    }
                    if (this.encrypted && this.useUnicodeMode) {
                        this.embeddedFonts = true;
                    }
                    //    CurrentPassNumber = 0;
                    //    MaximumPassNumber = (StiOptions.Export.Pdf.DivideSegmentPages ? 3 : 2);
                    var pages = pageRange.getSelectedPages(report.renderedPages);
                    // if (StiOptions.Export.Pdf.DivideSegmentPages) {
                    //    pages = StiSegmentPagesDivider.Divide(pages, this);
                    //    CurrentPassNumber++;
                    // }
                    //    #region Make bookmarks table
                    //    if ((report.Bookmark != null) && (report.Bookmark.Bookmarks.Count != 0)) {
                    //        AddBookmarkNode(report.Bookmark, -1);
                    //        haveBookmarks = true;
                    //        bookmarksCounter = bookmarksTree.Count;
                    //    }
                    //    #endregion
                    //#region Scan for assemble data
                    var tempPageNumber = 0;
                    for (var _i = 0, _a = pages.list; _i < _a.length; _i++) {
                        var page = _a[_i];
                        pages.getPage(page);
                        // InvokeExporting(tempPageNumber, pages.Count, CurrentPassNumber, MaximumPassNumber);
                        this.storeShadingData1(page.brush, tempPageNumber);
                        this.storeHatchData(page.brush);
                        //        if ((page.HyperlinkValue != null) && (page.HyperlinkValue.ToString().Trim().Length > 0) && (!page.HyperlinkValue.ToString().Trim().sti.startsWith("javascript:")) && !usePdfA) {
                        //            StiLinkObject stl = new StiLinkObject();
                        //            stl.Link = page.HyperlinkValue.ToString();
                        //            stl.Page = tempPageNumber;
                        //            linksArray.Add(stl);
                        //        }
                        if ((page.watermark != null) && (page.watermark.enabled)) {
                            if (!StiString.isNullOrEmpty(page.watermark.text)) {
                                if (page.watermark.font != null) {
                                    this.pdfFont.getFontNumber(page.watermark.font);
                                }
                                var sb = new StringBuilder(page.watermark.text);
                                sb = this.bidi.convert(sb, false);
                                this.pdfFont.storeUnicodeSymbolsInMap(sb);
                                this.storeShadingData1(page.watermark.textBrush, tempPageNumber);
                                this.storeHatchData(page.watermark.textBrush);
                            }
                            if (page.watermark.showImageBehind == true) {
                                if (page.watermark.image != null) {
                                    this.storeImageData(page.watermark.image, imageResolution, false, false);
                                }
                            }
                        }
                        for (var _b = 0, _c = page.components.list; _b < _c.length; _b++) {
                            var component = _c[_b];
                            if (component.enabled && !(report.isPrinting && !component.printable)) {
                                this.imageInfoCounter++;
                                // render components
                                var needPaint = (component.width > 0) && (component.height > 0);
                                if (needPaint) {
                                    var mBrush = component.sti.as(IStiBrush);
                                    if (mBrush != null) {
                                        this.storeShadingData1(mBrush.brush, tempPageNumber);
                                        this.storeHatchData(mBrush.brush);
                                    }
                                    var shape = component.sti.as(StiShape);
                                    if ((shape != null) && (Export.StiPdfRenderPrimitives.checkShape(shape)))
                                        continue;
                                    if (component.sti.is(StiCheckBox)) {
                                        var checkBox = component.sti.as(StiCheckBox);
                                        this.storeShadingData1(checkBox.textBrush, tempPageNumber);
                                        this.storeHatchData(checkBox.textBrush);
                                        if ((this.allowEditable == Export.StiPdfAllowEditable.Yes) && checkBox.editable) {
                                            var seo = new StiEditableObject();
                                            seo.Page = tempPageNumber;
                                            seo.Component = component;
                                            this.annots2Array.add(seo);
                                        }
                                        continue;
                                    }
                                    var isExportAsImage = component.isExportAsImage(Report.StiExportFormat.Pdf);
                                    if ( /* (this.exportRtfTextAsImage || !(component.sti.is(StiRichText))) && */isExportAsImage) {
                                        var flagIsImage = false;
                                        var imageTemp = component.sti.as(StiImage);
                                        if ((this.imageResolutionMode != Export.StiImageResolutionMode.Exactly) && (imageTemp != null)) {
                                            if ((imageTemp.imageToDraw != null) && (imageTemp.imageToDraw.bytes != null)) {
                                                flagIsImage = true;
                                                var rsImageResolution = imageTemp.imageToDraw.horizontalResolution / 100;
                                                if (this.imageResolutionMode == Export.StiImageResolutionMode.NoMoreThan) {
                                                    if (imageTemp.stretch) {
                                                        rsImageResolution = imageTemp.imageToDraw.width / report.unit.convertToHInches(component.width);
                                                    }
                                                    else {
                                                        rsImageResolution = 1 / imageTemp.multipleFactor;
                                                    }
                                                }
                                                rsImageResolution = this.storeImageData(imageTemp.imageToDraw, rsImageResolution, true, imageTemp.smoothing);
                                                this.imageInfoList.set(this.imageInfoCounter, rsImageResolution);
                                            }
                                        }
                                        if (!flagIsImage) {
                                            var exportImage = component.sti.as(IStiExportImageExtended);
                                            if (exportImage != null) {
                                                var rsImageResolution = imageResolution;
                                                var REFrsImageResolution = { ref: rsImageResolution };
                                                var image = exportImage.getImage(REFrsImageResolution, Report.StiExportFormat.Pdf);
                                                rsImageResolution = REFrsImageResolution.ref;
                                                if ((image != null) /*&& (imageTemp.imageToDraw.bytes != null)*/) {
                                                    this.storeImageData(image, rsImageResolution, false, false);
                                                    this.imageInfoList.set(this.imageInfoCounter, rsImageResolution);
                                                }
                                            }
                                        }
                                    }
                                    var mFont = component.sti.as(IStiFont);
                                    if (mFont != null) {
                                        var fnt = this.pdfFont.getFontNumber(mFont.font);
                                    }
                                    // make map of the unicode symbols
                                    var textOpt = component.sti.as(IStiTextOptions);
                                    if (component.sti.is(StiText) && (!isExportAsImage)) {
                                        var text = component.sti.as(StiText);
                                        var useRightToLeft = ((textOpt != null) && (textOpt.textOptions != null) && (textOpt.textOptions.rightToLeft));
                                        var sb = new StringBuilder(text.text);
                                        if (text.allowHtmlTags) {
                                            var baseTagsState = new Stimulsoft.Base.Drawing.StiHtmlTagsState(text.font.bold, text.font.italic, text.font.underline, text.font.strikeout, text.font.size, text.font.name, StiBrush.toColor(text.textBrush), StiBrush.toColor(text.brush), false, false, 0, 0, 1, text.horAlignment);
                                            var baseState = new Stimulsoft.Base.Drawing.StiHtmlState(baseTagsState, 0);
                                            var states = Stimulsoft.Base.Drawing.StiTextRenderer.parseHtmlToStates(text.text, baseState);
                                            sb = new StringBuilder();
                                            for (var index1 = 0; index1 < states.length; index1++) {
                                                var state = states[index1];
                                                sb.append(Stimulsoft.Base.Drawing.StiTextRenderer.prepareStateText(state.text));
                                            }
                                        }
                                        sb = this.bidi.convert(sb, useRightToLeft);
                                        this.pdfFont.storeUnicodeSymbolsInMap(sb);
                                        var mTextBrush = component.sti.as(IStiTextBrush);
                                        if ((text != null) && (mTextBrush != null)) {
                                            this.storeShadingData1(mTextBrush.textBrush, tempPageNumber);
                                            this.storeHatchData(mTextBrush.textBrush);
                                        }
                                        if ((this.allowEditable == Export.StiPdfAllowEditable.Yes) && text.editable) {
                                            var seo = new StiEditableObject();
                                            seo.Page = tempPageNumber;
                                            this.annotsArray.add(seo);
                                            this.fontGlyphsReduceNotNeed[this.pdfFont.currentFont] = true;
                                        }
                                    }
                                    //                    if (!exportRtfTextAsImage && (component is StiRichText))
                                    //                    {
                                    //                        mfRender.AssembleRtf(component);
                                    //                    }
                                    if (component.sti.is(StiBarCode) && !isExportAsImage) {
                                        var pdfGeomWriter = new Export.StiPdfGeomWriter(this.pageStream, this, true);
                                        var barCodePainter = Export.StiBarCodeExportPainter.createNew(pdfGeomWriter);
                                        var barCode = component.sti.as(StiBarCode);
                                        if (!StiString.isNullOrEmpty(barCode.codeValue) && barCode.page != null) {
                                            var rectf = report.unit.convertToHInches(barCode.clientRectangle);
                                            barCode.barCodeType.draw(barCodePainter, barCode, rectf, 1);
                                        }
                                    }
                                    else if (component.sti.is(IStiChart) && !isExportAsImage) {
                                        var pp = new StiPdfData(this);
                                        pp.Component = component;
                                        Export.StiPdfRenderChart.renderChart(pp, true, tempPageNumber);
                                    }
                                }
                                //                if ((component.HyperlinkValue != null) && (component.HyperlinkValue.ToString().Trim().Length > 0) && (!component.HyperlinkValue.ToString().Trim().sti.startsWith("javascript:")) && !usePdfA) {
                                //                    StiLinkObject stl = new StiLinkObject();
                                //                    stl.Link = component.HyperlinkValue.ToString();
                                //                    stl.Page = tempPageNumber;
                                //                    linksArray.Add(stl);
                                //                }
                                //                if ((component.ToolTipValue != null) && (component.ToolTipValue.ToString().Trim().Length > 0) && !usePdfA) {
                                //                    StiLinkObject stl = new StiLinkObject();
                                //                    //stl.Link = component.ToolTipValue.ToString();
                                //                    stl.Page = tempPageNumber;
                                //                    tooltipsArray.Add(stl);
                                //                }
                                //                if ((component.TagValue != null) && (component.TagValue.ToString().ToLower(Stimulsoft.System.Globalization.CultureInfo.InvariantCulture) == "pdfunsignedsignaturefield") && !usePdfA) {
                                //                    let stl = new StiEditableObject();
                                //                    stl.Page = tempPageNumber;
                                //                    unsignedSignaturesArray.Add(stl);
                                //                }
                                //                if ((useDigitalSignature) && (!haveDigitalSignature) && (component.TagValue != null) && (component.TagValue.ToString().ToLower(Stimulsoft.System.Globalization.CultureInfo.InvariantCulture) == "pdfdigitalsignature")) {
                                //                    signaturePageNumber = tempPageNumber;
                                //                    haveDigitalSignature = true;
                                //                }
                            }
                        }
                        tempPageNumber++;
                        if ((page.watermark != null) && (page.watermark.enabled)) {
                            if (page.watermark.showImageBehind == false) {
                                if (page.watermark.image != null) {
                                    this.storeImageData(page.watermark.image, imageResolution, false, false);
                                }
                            }
                        }
                    }
                    // for trimming
                    for (var indexFont = 0; indexFont < this.pdfFont.fontList.length; indexFont++) {
                        this.pdfFont.currentFont = indexFont;
                        this.pdfFont.storeUnicodeSymbolsInMap(new StringBuilder("…"));
                    }
                    //    if ((unsignedSignaturesArray.Count > 0) && (annotsArray.Count > 0 || annots2Array.Count > 0)) {
                    //        for (int indexFont = 0; indexFont < this.pdfFont.fontList.Count; indexFont++)
                    //        {
                    //            let font = (PdfFonts.pfontInfo)pdfFont.fontList[indexFont];
                    //            if (font.Name == "Arial") {
                    //                fontGlyphsReduceNotNeed[indexFont] = true;
                    //            }
                    //        }
                    //    }
                    // prepare codepage1252 string
                    var sbb = new StringBuilder();
                    for (var indexs = 32; indexs < 256; indexs++) {
                        sbb.append(String.fromCharCode(this.CodePage1252[indexs]));
                    }
                    // add all codepage1252 to symbols
                    for (var indexf = 0; indexf < this.pdfFont.fontList.length; indexf++) {
                        if (this.fontGlyphsReduceNotNeed[indexf]) {
                            this.pdfFont.currentFont = indexf;
                            this.pdfFont.storeUnicodeSymbolsInMap(sbb);
                        }
                    }
                    this.imagesCurrent = 0;
                    this.annotsCurrent = 0;
                    this.annots2Current = 0;
                    this.shadingCurrent = 0;
                    // this.linksCounter = linksArray.Count;
                    // this.haveLinks = linksCounter > 0;
                    this.annotsCounter = this.annotsArray.length;
                    this.annots2Counter = this.annots2Array.length;
                    this.unsignedSignaturesCounter = this.unsignedSignaturesArray.length;
                    this.haveAnnots = this.annotsCounter > 0 || this.annots2Counter > 0 || this.unsignedSignaturesCounter > 0;
                    // this.tooltipsCounter = tooltipsArray.Count;
                    // this.haveTooltips = tooltipsCounter > 0;
                    //    int imagesMaskCounter = 0;
                    //    for (int indexMask = 0; indexMask < imageCache.ImageMaskStore.Count; indexMask++)
                    //    {
                    //        if (imageCache.ImageMaskStore[indexMask] != null) imagesMaskCounter++;
                    //    }
                    //    #endregion
                    //    if (useDigitalSignature && (!haveDigitalSignature)) {
                    //        haveDigitalSignature = true;
                    //        signaturePageNumber = 0;
                    //        StiPage page = pages[0];
                    //        double pageHeight2 = this.hiToTwips * report.Unit.ConvertToHInches(page.PageHeight * page.SegmentPerHeight);
                    //        double pageWidth2 = this.hiToTwips * report.Unit.ConvertToHInches(page.PageWidth * page.SegmentPerWidth);
                    //        double mgLeft2 = this.hiToTwips * report.Unit.ConvertToHInches(page.Margins.Left);
                    //        double mgRight2 = this.hiToTwips * report.Unit.ConvertToHInches(page.Margins.Right);
                    //        double mgTop2 = this.hiToTwips * report.Unit.ConvertToHInches(page.Margins.Top);
                    //        double mgBottom2 = this.hiToTwips * report.Unit.ConvertToHInches(page.Margins.Bottom);
                    //        signaturePlacement = new RectangleD(0, pageHeight2 - mgTop2, mgLeft2, mgBottom2);
                    //    }
                    this.pdfFont.InitFontsData(report);
                    this.fontsCounter = this.pdfFont.fontList.length;
                    // Fill structure info
                    this.info = new Export.StiPdfStructure();
                    for (var index = 0; index < pages.count; index++) {
                        this.info.pageList.add(this.info.createContentObject(true));
                    }
                    for (var index = 0; index < this.imageCache.imagePackedStore.length; index++) {
                        this.info.xObjectList.add(this.info.createXObject(true, this.imageCache.imageMaskStore[index] != null));
                    }
                    for (var index = 0; index < this.pdfFont.fontList.length; index++) {
                        this.info.fontList.add(this.info.createFontObject(true, this.useUnicodeMode, this.standardPdfFonts, this.embeddedFonts));
                    }
                    this.info.outlines = this.info.createOutlinesObject(this.haveBookmarks);
                    if (this.haveBookmarks) {
                        for (var index = 0; index < this.bookmarksCounter; index++) {
                            this.info.outlines.items.add(this.info.createObject(true));
                        }
                    }
                    this.info.patterns = this.info.createPatternsObject(true);
                    for (var index = 0; index < this.hatchArray.length; index++) {
                        this.info.patterns.hatchItems.add(this.info.createObject(true));
                    }
                    for (var index = 0; index < this.shadingArray.length; index++) {
                        this.info.patterns.shadingItems.add(this.info.createShadingObject(true));
                    }
                    for (var index = 0; index < this.linksCounter; index++) {
                        this.info.linkList.add(this.info.createObject(true));
                    }
                    this.info.encode = this.info.createObject(this.encrypted);
                    this.info.extGState = this.info.createObject(true);
                    this.info.acroForm = this.info.createAcroFormObject(this.haveAnnots /* || this.haveDigitalSignature */ || this.haveTooltips);
                    if (this.haveAnnots) {
                        for (var index = 0; index < this.annotsCounter; index++) {
                            this.info.acroForm.annots.add(this.info.createAnnotObject(true, true, 0));
                        }
                        for (var index = 0; index < this.fontsCounter; index++) {
                            this.info.acroForm.annotFontItems.add(this.info.createFontObject(true, false, false, false, true));
                        }
                        for (var index = 0; index < this.annots2Counter; index++) {
                            this.info.acroForm.checkBoxes.add(new Export.StiPdfCheckBoxObjInfo());
                            this.info.acroForm.checkBoxes[index].items = [];
                            this.info.acroForm.checkBoxes[index].items.add(this.info.createAnnotObject(true, true, 2));
                            this.info.acroForm.checkBoxes[index].items.add(this.info.createAnnotObject(true, true, 2));
                            if (this.annots2Array[index].Component.sti.as(StiCheckBox).checkedValue == null) {
                                this.info.acroForm.checkBoxes[index].items.add(this.info.createAnnotObject(true, false, 2));
                            }
                        }
                        // for (let index: number = 0; index < unsignedSignaturesCounter; index++)
                        // {
                        //    this.info.acroForm.UnsignedSignatures.add(this.info.createAnnotObject(true, false, 0));
                        // }
                    }
                    // this.info.acroForm.signatures.add(this.info.createAnnotObject(this.haveDigitalSignature, true, 0));
                    for (var index = 0; index < this.tooltipsCounter; index++) {
                        this.info.acroForm.tooltips.add(this.info.createAnnotObject(true, false, 0));
                    }
                    this.info.metadata = this.info.createObject(true);
                    this.info.destOutputProfile = this.info.createObject(true);
                    this.info.outputIntents = this.info.createObject(true);
                    this.info.embeddedJS = this.info.createContentObject(this.autoPrint != Export.StiPdfAutoPrintMode.None);
                    // if (this.embeddedFiles != null && this.embeddedFiles.Count > 0) {
                    //    foreach(let element in embeddedFiles)
                    //    {
                    //        info.EmbeddedFilesList.Add(info.CreateContentObject(true));
                    //    }
                    // }
                    this.renderStartDoc(report, pages);
                    // Write data
                    var pageNumber = 0;
                    // linksArray.Clear();
                    // tagsArray = new List<StiLinkObject>();
                    // tooltipsArray.Clear();
                    // unsignedSignaturesArray.Clear();
                    this.imageInfoCounter = 0;
                    this.currentPassNumber++;
                    for (var _d = 0, _e = pages.list; _d < _e.length; _d++) {
                        var page = _e[_d];
                        pages.getPage(page);
                        // this.invokeExporting(pageNumber, pages.Count, CurrentPassNumber, MaximumPassNumber);
                        if (this.isStopped)
                            return;
                        this.renderPageHeader(pageNumber++);
                        var pageHeight = this.hiToTwips * report.unit.convertToHInches(page.pageHeight * page.segmentPerHeight);
                        var pageWidth = this.hiToTwips * report.unit.convertToHInches(page.pageWidth * page.segmentPerWidth);
                        var mgLeft = this.hiToTwips * report.unit.convertToHInches(page.margins.left);
                        var mgRight = this.hiToTwips * report.unit.convertToHInches(page.margins.right);
                        var mgTop = this.hiToTwips * report.unit.convertToHInches(page.margins.top);
                        var mgBottom = this.hiToTwips * report.unit.convertToHInches(page.margins.bottom);
                        if (pageHeight > 14400) {
                            pageHeight = 14400; // Adobe Acrobat limitation of page size: maximum 200" * 200"
                        }
                        //        #region bookmarks on pages
                        //        if (report.Bookmark.Engine == StiEngineVersion.EngineV1) {
                        //            if ((haveBookmarks == true) && (page.BookmarkValue != null) && ((string)page.BookmarkValue != ""))
                        //            {
                        //                bool bookmarkFinded = false;
                        //                int tempIndex = 0;
                        //                while ((bookmarkFinded == false) && (tempIndex < bookmarksCounter)) {
                        //                    StiBookmarkTreeNode tn = (StiBookmarkTreeNode)bookmarksTree[tempIndex];
                        //                    if ((tn.Used == false) && (tn.Page == -1) && (tn.Title == (string)page.BookmarkValue))
                        //                    {
                        //                        tn.Page = pageNumber - 1;
                        //                        tn.Y = pageHeight;
                        //                        tn.Used = true;
                        //                        bookmarkFinded = true;
                        //                        bookmarksTree[tempIndex] = tn;
                        //                        break;
                        //                    }
                        //                    tempIndex++;
                        //                }
                        //            }
                        //        }
                        //        else {
                        //            if ((haveBookmarks == true) && (!string.IsNullOrEmpty(page.Guid) || ((page.BookmarkValue != null) && ((string)page.BookmarkValue != ""))))
                        //            {
                        //                int tempIndex = 0;
                        //                while (tempIndex < bookmarksCounter) {
                        //                    StiBookmarkTreeNode tn = (StiBookmarkTreeNode)bookmarksTree[tempIndex];
                        //                    if ((tn.Used == false) && (tn.Page == -1)) {
                        //                        bool finded = false;
                        //                        if (!string.IsNullOrEmpty(tn.Guid)) {
                        //                            if (!string.IsNullOrEmpty(page.Guid) && (tn.Guid == page.Guid)) finded = true;
                        //                        }
                        //                        else if (!string.IsNullOrEmpty(tn.Title)) {
                        //                            if ((page.BookmarkValue != null) && (((string)page.BookmarkValue).Length > 0) && (tn.Title == (string)page.BookmarkValue)) finded = true;
                        //                        }
                        //                        if (finded) {
                        //                            tn.Page = pageNumber - 1;
                        //                            tn.Y = pageHeight;
                        //                            tn.Used = true;
                        //                            bookmarksTree[tempIndex] = tn;
                        //                            break;
                        //                        }
                        //                    }
                        //                    tempIndex++;
                        //                }
                        //            }
                        //        }
                        //        #endregion
                        //        #region hyperlinks on page
                        //        if ((page.HyperlinkValue != null) && (page.HyperlinkValue.ToString().Trim().Length > 0) && (!page.HyperlinkValue.ToString().Trim().sti.startsWith("javascript:")) && !usePdfA) {
                        //            StiLinkObject stl = new StiLinkObject();
                        //            stl.Link = page.HyperlinkValue.ToString();
                        //            stl.X = 0;
                        //            stl.Y = 0;
                        //            stl.Width = pageWidth;
                        //            stl.Height = pageHeight;
                        //            stl.Page = pageNumber;
                        //            stl.DestPage = -1;
                        //            stl.DestY = -1;
                        //            linksArray.Add(stl);
                        //        }
                        //        #endregion
                        //        #region Render page
                        if (page.brush != null) {
                            var pp = new StiPdfData(this);
                            pp.X = 0;
                            pp.Y = 0;
                            pp.Width = pageWidth;
                            pp.Height = pageHeight;
                            var cont = new StiContainer();
                            cont.brush = page.brush;
                            cont.border = null;
                            pp.Component = cont;
                            Export.StiPdfRenderPrimitives.renderBorder1(pp); // fullpage fill
                        }
                        this.renderWatermark(page, true, pageWidth, pageHeight, imageResolution);
                        var storedBorders = new Array();
                        for (var _f = 0, _g = page.components.list; _f < _g.length; _f++) {
                            var component = _g[_f];
                            if (component.enabled && !(report.isPrinting && !component.printable)) {
                                this.imageInfoCounter++;
                                var x1 = this.hiToTwips * report.unit.convertToHInches(component.left);
                                var y1 = this.hiToTwips * report.unit.convertToHInches(component.top);
                                var x2 = this.hiToTwips * report.unit.convertToHInches(component.right);
                                var y2 = this.hiToTwips * report.unit.convertToHInches(component.bottom);
                                var pp = new StiPdfData(this);
                                pp.X = x1 + mgLeft;
                                pp.Y = y1 + mgTop;
                                pp.Width = x2 - x1;
                                pp.Height = y2 - y1;
                                pp.Y = pageHeight - (pp.Y + pp.Height);
                                pp.Component = component;
                                var needPaint = (component.width > 0) && (component.height > 0);
                                if (needPaint) {
                                    var isExportAsImage = component.isExportAsImage(Report.StiExportFormat.Pdf);
                                    if (!this.usePdfA && !component.printable) {
                                        this.pageStream.writeLine("/OC /oc1 BDC");
                                    }
                                    if (!(component.sti.is(StiShape))) {
                                        Export.StiPdfRenderPrimitives.renderBorder1(pp);
                                    }
                                    if (component.sti.is(StiText) && !isExportAsImage) {
                                        var stiText = component.sti.as(StiText);
                                        // prepare annot
                                        var memPos = 0;
                                        if (this.haveAnnots && stiText.editable) {
                                            memPos = this.pageStream.position;
                                            // some correction - GS is not supported in editable
                                            this.pushColorToStack();
                                            this.lastColorStrokeA = 0xFF;
                                            this.lastColorNonStrokeA = 0xFF;
                                        }
                                        if (stiText.allowHtmlTags) {
                                            // renderText2(pp);
                                            var baseTagsState = new Stimulsoft.Base.Drawing.StiHtmlTagsState(stiText.font.bold, stiText.font.italic, stiText.font.underline, stiText.font.strikeout, stiText.font.size, stiText.font.name, StiBrush.toColor(stiText.textBrush), StiBrush.toColor(stiText.brush), false, false, 0, 0, 1, stiText.horAlignment);
                                            var baseState = new Stimulsoft.Base.Drawing.StiHtmlState(baseTagsState, 0);
                                            var states = Stimulsoft.Base.Drawing.StiTextRenderer.parseHtmlToStates(stiText.text, baseState);
                                            var sb = new StringBuilder();
                                            for (var index1 = 0; index1 < states.length; index1++) {
                                                var state = states[index1];
                                                sb.append(Stimulsoft.Base.Drawing.StiTextRenderer.prepareStateText(state.text));
                                            }
                                            var text2 = stiText.clone(true);
                                            text2.text = sb.toString();
                                            pp.Component = text2;
                                            Export.StiPdfRenderText.renderTextFont(pp);
                                            Export.StiPdfRenderText.renderText(pp);
                                            // Store editable info
                                            if (this.haveAnnots && stiText.editable) {
                                                var seo = this.annotsArray[this.annotsCurrent];
                                                seo.Multiline = stiText.wordWrap;
                                                seo.X = pp.X;
                                                seo.Y = pp.Y;
                                                seo.Width = pp.Width;
                                                seo.Height = pp.Height;
                                                seo.Component = pp.Component;
                                                seo.Alignment = Stimulsoft.Base.Drawing.StiTextHorAlignment.Left;
                                                var mTextHorAlign = pp.Component.sti.as(IStiTextHorAlignment);
                                                if (mTextHorAlign != null) {
                                                    var horAlign = mTextHorAlign.horAlignment;
                                                    var textOpt = pp.Component.sti.as(IStiTextOptions);
                                                    if (textOpt != null && textOpt.textOptions != null && textOpt.textOptions.rightToLeft) {
                                                        if (horAlign == Stimulsoft.Base.Drawing.StiTextHorAlignment.Left)
                                                            horAlign = Stimulsoft.Base.Drawing.StiTextHorAlignment.Right;
                                                        else if (horAlign == Stimulsoft.Base.Drawing.StiTextHorAlignment.Right)
                                                            horAlign = Stimulsoft.Base.Drawing.StiTextHorAlignment.Left;
                                                    }
                                                    seo.Alignment = horAlign;
                                                }
                                                seo.Text = sb.toString().sti.replaceAll("\n", "");
                                            }
                                        }
                                        else {
                                            Export.StiPdfRenderText.renderTextFont(pp);
                                            Export.StiPdfRenderText.renderText(pp);
                                        }
                                        // end annot
                                        if (this.haveAnnots && stiText.editable) {
                                            this.pageStream.flush();
                                            var memPos2 = this.pageStream.position;
                                            this.pageStream.seek(memPos, Stimulsoft.System.IO.SeekOrigin.Begin);
                                            var bufAnnot = []; // new byte[memPos2 - memPos];
                                            this.pageStream.read(bufAnnot, 0, memPos2 - memPos);
                                            this.pageStream.seek(memPos, Stimulsoft.System.IO.SeekOrigin.Begin);
                                            this.pageStream.setLength(memPos);
                                            var seo = this.annotsArray[this.annotsCurrent];
                                            seo.Content = bufAnnot;
                                            this.annotsCurrent++;
                                            // some correction - GS is not supported in editable
                                            this.popColorFromStack();
                                        }
                                    }
                                    if (component.sti.is(StiShape))
                                        Export.StiPdfRenderPrimitives.renderShape(pp, imageResolution);
                                    else if (component.sti.is(StiBarCode) && !isExportAsImage) {
                                        //#regionRender barcode
                                        var pdfGeomWriter = new Export.StiPdfGeomWriter(this.pageStream, this);
                                        var barCodePainter = Export.StiBarCodeExportPainter.createNew(pdfGeomWriter);
                                        var barCode = component.sti.as(StiBarCode);
                                        if (!StiString.isNullOrEmpty(barCode.codeValue) && barCode.page != null) {
                                            this.pageStream.writeLine("q");
                                            this.pushColorToStack();
                                            this.pageStream.writeLine("{0} {1} {2} {3} re W n", this.convertToString(pp.X), this.convertToString(pp.Y), this.convertToString(pp.Width), this.convertToString(pp.Height));
                                            this.pageStream.writeLine("1 0 0 1 {0} {1} cm", this.convertToString(mgLeft), this.convertToString(pageHeight - mgTop));
                                            this.pageStream.writeLine("1 0 0 -1 0 0 cm");
                                            this.pageStream.writeLine("{0} 0 0 {0} 0 0 cm", this.convertToString(this.hiToTwips));
                                            var rectf = report.unit.convertToHInches(barCode.clientRectangle);
                                            barCode.barCodeType.draw(barCodePainter, barCode, rectf, 1);
                                            this.pageStream.writeLine("Q");
                                            this.popColorFromStack();
                                        }
                                        //#endregion
                                    }
                                    else if (component.sti.is(IStiChart) && !isExportAsImage) {
                                        this.pageStream.writeLine("q");
                                        this.pushColorToStack();
                                        //// pageStream.WriteLine("{0} {1} {2} {3} re W n",
                                        ////    ConvertToString(pp.X),
                                        ////    ConvertToString(pp.Y),
                                        ////    ConvertToString(pp.Width),
                                        ////    ConvertToString(pp.Height));
                                        this.pageStream.writeLine("1 0 0 1 {0} {1} cm", this.convertToString(pp.X), this.convertToString(pp.Y + pp.Height));
                                        this.pageStream.writeLine("1 0 0 -1 0 0 cm");
                                        this.pageStream.writeLine("{0} 0 0 {0} 0 0 cm", this.convertToString(this.hiToTwips / 0.96));
                                        Export.StiPdfRenderChart.renderChart(pp, false, pageNumber - 1);
                                        this.pageStream.writeLine("Q");
                                        this.popColorFromStack();
                                    }
                                    else {
                                        // if (!this.exportRtfTextAsImage && (component.sti.is(StiRichText)))
                                        // {
                                        //    this.mfRender.RenderRtf(pp);
                                        // }
                                        // else
                                        // {
                                        if (component.sti.is(StiCheckBox)) {
                                            var checkbox = component.sti.as(StiCheckBox);
                                            if (this.haveAnnots && checkbox.editable) {
                                                // store annots info
                                                var seo = this.annots2Array[this.annots2Current];
                                                seo.Multiline = false;
                                                seo.X = pp.X;
                                                seo.Y = pp.Y;
                                                seo.Width = pp.Width;
                                                seo.Height = pp.Height;
                                                seo.Component = pp.Component;
                                                seo.Alignment = Stimulsoft.Base.Drawing.StiTextHorAlignment.Center;
                                                seo.Text = "";
                                                //#endregion
                                                var storeX = pp.X;
                                                var storeY = pp.Y;
                                                pp.X = 0;
                                                pp.Y = 0;
                                                //#region prepare annot
                                                this.pageStream.flush();
                                                var memPos = this.pageStream.position;
                                                // some correction - GS is not supported in editable
                                                this.pushColorToStack();
                                                this.lastColorStrokeA = 0xFF;
                                                this.lastColorNonStrokeA = 0xFF;
                                                //#endregion
                                                Export.StiPdfRenderPrimitives.renderCheckbox(pp, true);
                                                //#region end annot
                                                this.pageStream.flush();
                                                var memPos2 = this.pageStream.position;
                                                this.pageStream.seek(memPos, Stimulsoft.System.IO.SeekOrigin.Begin);
                                                var bufAnnot = []; // new byte[memPos2 - memPos];
                                                this.pageStream.read(bufAnnot, 0, memPos2 - memPos);
                                                this.pageStream.seek(memPos, Stimulsoft.System.IO.SeekOrigin.Begin);
                                                seo.Content = bufAnnot;
                                                // some correction - GS is not supported in editable
                                                this.popColorFromStack();
                                                //#endregion
                                                //#region prepare annot
                                                this.pageStream.flush();
                                                memPos = this.pageStream.position;
                                                // some correction - GS is not supported in editable
                                                this.pushColorToStack();
                                                this.lastColorStrokeA = 0xFF;
                                                this.lastColorNonStrokeA = 0xFF;
                                                //#endregion
                                                Export.StiPdfRenderPrimitives.renderCheckbox(pp, false, false);
                                                //#region end annot
                                                this.pageStream.flush();
                                                memPos2 = this.pageStream.position;
                                                this.pageStream.seek(memPos, Stimulsoft.System.IO.SeekOrigin.Begin);
                                                bufAnnot = []; // new byte[memPos2 - memPos];
                                                this.pageStream.read(bufAnnot, 0, memPos2 - memPos);
                                                this.pageStream.seek(memPos, Stimulsoft.System.IO.SeekOrigin.Begin);
                                                seo.Content2 = bufAnnot;
                                                // some correction - GS is not supported in editable
                                                this.popColorFromStack();
                                                //#endregion
                                                this.annots2Current++;
                                                pp.X = storeX;
                                                pp.Y = storeY;
                                            }
                                            else {
                                                var checkboxValue = Export.StiPdfRenderPrimitives.getCheckBoxValue(checkbox);
                                                if (checkboxValue != null) {
                                                    Export.StiPdfRenderPrimitives.renderCheckbox(pp, checkboxValue);
                                                }
                                            }
                                        }
                                        else if (isExportAsImage) {
                                            this.renderImage(pp, imageResolution);
                                        }
                                        // }
                                    }
                                    if (component.sti.is(StiRectanglePrimitive)) {
                                        Export.StiPdfRenderPrimitives.renderRoundedRectanglePrimitive(pp);
                                    }
                                    else {
                                        var mBorder = pp.Component.sti.as(IStiBorder);
                                        if ((mBorder != null) && (mBorder.border != null) && (mBorder.border.topmost)) {
                                            storedBorders.add(pp);
                                        }
                                        else {
                                            Export.StiPdfRenderPrimitives.renderBorder2(pp);
                                        }
                                    }
                                    if (!this.usePdfA && !component.printable) {
                                        this.pageStream.writeLine("EMC");
                                    }
                                }
                                //                #region bookmarks on components
                                //                if (report.Bookmark.Engine == StiEngineVersion.EngineV1) {
                                //                    if ((haveBookmarks == true) && (component.BookmarkValue != null) && ((string)component.BookmarkValue != ""))
                                //                    {
                                //                        bool bookmarkFinded = false;
                                //                        int tempIndex = 0;
                                //                        while ((bookmarkFinded == false) && (tempIndex < bookmarksCounter)) {
                                //                            StiBookmarkTreeNode tn = (StiBookmarkTreeNode)bookmarksTree[tempIndex];
                                //                            if ((tn.Used == false) && (tn.Page == -1) && (tn.Title == (string)component.BookmarkValue))
                                //                            {
                                //                                tn.Page = pageNumber - 1;
                                //                                tn.Y = pp.Y + pp.Height;
                                //                                tn.Used = true;
                                //                                bookmarkFinded = true;
                                //                                bookmarksTree[tempIndex] = tn;
                                //                                break;
                                //                            }
                                //                            tempIndex++;
                                //                        }
                                //                    }
                                //                }
                                //                else {
                                //                    if ((haveBookmarks == true) && (!string.IsNullOrEmpty(component.Guid) || ((component.BookmarkValue != null) && ((string)component.BookmarkValue != ""))))
                                //                    {
                                //                        int tempIndex = 0;
                                //                        while (tempIndex < bookmarksCounter) {
                                //                            StiBookmarkTreeNode tn = (StiBookmarkTreeNode)bookmarksTree[tempIndex];
                                //                            if ((tn.Used == false) && (tn.Page == -1)) {
                                //                                bool finded = false;
                                //                                if (!string.IsNullOrEmpty(tn.Guid)) {
                                //                                    if ((!string.IsNullOrEmpty(component.Guid)) && (tn.Guid == component.Guid)) finded = true;
                                //                                }
                                //                                else if (!string.IsNullOrEmpty(tn.Title)) {
                                //                                    if ((component.BookmarkValue != null) && (((string)component.BookmarkValue).Length > 0) && (tn.Title == (string)component.BookmarkValue)) finded = true;
                                //                                }
                                //                                if (finded) {
                                //                                    tn.Page = pageNumber - 1;
                                //                                    tn.Y = pp.Y + pp.Height;
                                //                                    tn.Used = true;
                                //                                    bookmarksTree[tempIndex] = tn;
                                //                                    break;
                                //                                }
                                //                            }
                                //                            tempIndex++;
                                //                        }
                                //                    }
                                //                }
                                //                #endregion
                                //                #region hyperlinks on components
                                //                if ((component.HyperlinkValue != null) && (component.HyperlinkValue.ToString().Trim().Length > 0) && (!component.HyperlinkValue.ToString().Trim().sti.startsWith("javascript:")) && !usePdfA) {
                                //                    StiLinkObject stl = new StiLinkObject();
                                //                    stl.Link = component.HyperlinkValue.ToString();
                                //                    stl.X = pp.X;
                                //                    stl.Y = pp.Y;
                                //                    stl.Width = pp.Width;
                                //                    stl.Height = pp.Height;
                                //                    stl.Page = pageNumber;
                                //                    stl.DestPage = -1;
                                //                    stl.DestY = -1;
                                //                    linksArray.Add(stl);
                                //                }
                                //                #endregion
                                //                #region tags on components
                                //                if ((component.TagValue != null) && (component.TagValue.ToString().Trim().Length > 0)) {
                                //                    StiLinkObject stl = new StiLinkObject();
                                //                    stl.Link = component.TagValue.ToString();
                                //                    stl.X = pp.X;
                                //                    stl.Y = pp.Y;
                                //                    stl.Width = pp.Width;
                                //                    stl.Height = pp.Height;
                                //                    stl.Page = pageNumber - 1;
                                //                    stl.DestPage = -1;
                                //                    stl.DestY = -1;
                                //                    tagsArray.Add(stl);
                                //                    if (stl.Link.Trim().ToLower(Stimulsoft.System.Globalization.CultureInfo.InvariantCulture) == "pdfunsignedsignaturefield" && !usePdfA) {
                                //                        let ste = new StiEditableObject();
                                //                        ste.X = stl.X;
                                //                        ste.Y = stl.Y;
                                //                        ste.Width = stl.Width;
                                //                        ste.Height = stl.Height;
                                //                        ste.Page = stl.Page;
                                //                        ste.Component = component;
                                //                        unsignedSignaturesArray.Add(ste);
                                //                    }
                                //                }
                                //                #endregion
                                //                #region tooltips on components
                                //                if ((component.ToolTipValue != null) && (component.ToolTipValue.ToString().Trim().Length > 0) && !usePdfA) {
                                //                    StiLinkObject stl = new StiLinkObject();
                                //                    stl.Link = component.ToolTipValue.ToString().Trim();
                                //                    stl.X = pp.X;
                                //                    stl.Y = pp.Y;
                                //                    stl.Width = pp.Width;
                                //                    stl.Height = pp.Height;
                                //                    stl.Page = pageNumber - 1;
                                //                    stl.DestPage = -1;
                                //                    stl.DestY = -1;
                                //                    tooltipsArray.Add(stl);
                                //                }
                                //                #endregion
                                //                #region digital signature on component
                                //                if ((component.TagValue != null) && (component.TagValue.ToString().ToLower(Stimulsoft.System.Globalization.CultureInfo.InvariantCulture) == "pdfdigitalsignature")) {
                                //                    signaturePlacement = new RectangleD(pp.X, pp.Y, pp.Width, pp.Height);
                                //                }
                                //                #endregion
                            }
                        }
                        for (var _h = 0, storedBorders_1 = storedBorders; _h < storedBorders_1.length; _h++) {
                            var ppd = storedBorders_1[_h];
                            Export.StiPdfRenderPrimitives.renderBorder2(ppd);
                        }
                        storedBorders.clear();
                        if (page.border != null) {
                            var pp = new StiPdfData(this);
                            pp.X = mgLeft;
                            pp.Y = mgBottom;
                            pp.Width = pageWidth - mgLeft - mgRight;
                            pp.Height = pageHeight - mgTop - mgBottom;
                            var cont = new StiContainer();
                            cont.border = page.border;
                            pp.Component = cont;
                            Export.StiPdfRenderPrimitives.renderBorder2(pp);
                        }
                        this.renderWatermark(page, false, pageWidth, pageHeight, imageResolution);
                        this.renderPageFooter(pageHeight, pageWidth);
                    }
                    //    #region Remake bookmarks table
                    //    bookmarksTreeTemp = null;
                    //    if (haveBookmarks && deleteEmptyBookmarks) {
                    //        //mark node path
                    //        for (int indexNode = 0; indexNode < bookmarksTree.Count; indexNode++)
                    //        {
                    //            StiBookmarkTreeNode tn = (StiBookmarkTreeNode)bookmarksTree[indexNode];
                    //            if (tn.Used) {
                    //                while (tn.Parent != -1) {
                    //                    tn = (StiBookmarkTreeNode)bookmarksTree[tn.Parent];
                    //                    tn.Used = true;
                    //                }
                    //            }
                    //        }
                    //        //make new Bookmarks
                    //        StiBookmark rootBookmark = new StiBookmark();
                    //        MakeBookmarkFromTree(rootBookmark, (StiBookmarkTreeNode)bookmarksTree[0]);
                    //        bookmarksTreeTemp = bookmarksTree;
                    //        bookmarksTree = new ArrayList();
                    //        AddBookmarkNode(rootBookmark, -1);
                    //        //add empty records
                    //        int numberNodesToAdd = bookmarksCounter - bookmarksTree.Count;
                    //        if (numberNodesToAdd > 0) {
                    //            StiBookmarkTreeNode tn = new StiBookmarkTreeNode();
                    //            tn.Parent = -1;
                    //            tn.First = -1;
                    //            tn.Last = -1;
                    //            tn.Prev = -1;
                    //            tn.Next = -1;
                    //            tn.Count = -1;
                    //            tn.Page = -1;
                    //            tn.Y = -1;
                    //            tn.Title = "";
                    //            for (int indexNode = 0; indexNode < numberNodesToAdd; indexNode++)
                    //            {
                    //                bookmarksTree.Add(tn);
                    //            }
                    //        }
                    //        //fill new Bookmarks
                    //        Hashtable htNameToNode = new Hashtable();
                    //        for (int indexBookmark = 0; indexBookmark < bookmarksTreeTemp.Count; indexBookmark++)
                    //        {
                    //            StiBookmarkTreeNode tn = (StiBookmarkTreeNode)bookmarksTreeTemp[indexBookmark];
                    //            htNameToNode[tn.Title] = tn;
                    //        }
                    //        for (int indexBookmark = 0; indexBookmark < bookmarksTree.Count; indexBookmark++)
                    //        {
                    //            StiBookmarkTreeNode tn = (StiBookmarkTreeNode)bookmarksTree[indexBookmark];
                    //            if (!string.IsNullOrEmpty(tn.Title)) {
                    //                StiBookmarkTreeNode tnOld = (StiBookmarkTreeNode)htNameToNode[tn.Title];
                    //                tn.Page = tnOld.Page;
                    //                tn.Y = tnOld.Y;
                    //            }
                    //        }
                    //        bookmarksTreeTemp = null;
                    //    }
                    this.renderImageTable();
                    this.renderFontTable();
                    //    RenderBookmarksTable();
                    this.renderPatternTable();
                    //    RenderLinkTable();
                    this.renderEncodeRecord();
                    this.renderExtGStateRecord();
                    this.renderAnnotTable();
                    //    RenderSignatureTable(report);
                    //    RenderTooltipTable();
                    this.renderMetadata(report);
                    this.renderColorSpace();
                    this.renderAutoPrint();
                    this.renderEndDoc();
                    //#region Clear
                    //    imageList.Clear();
                    //    imageList = null;
                    //    imageInterpolationTable.Clear();
                    //    imageInterpolationTable = null;
                    //    imageCacheIndexToList.Clear();
                    //    imageCacheIndexToList = null;
                    //    imageInfoList.Clear();
                    //    imageInfoList = null;
                    this.xref = null;
                    //    bookmarksTree = null;
                    //    linksArray = null;
                    //    tagsArray = null;
                    //    tooltipsArray = null;
                    this.annotsArray = null;
                    this.annots2Array = null;
                    this.unsignedSignaturesArray = null;
                    this.shadingArray = null;
                    this.hatchArray = null;
                    this.colorStack = null;
                    //    enc = null;
                    //    if (graphicsForTextRenderer != null) graphicsForTextRenderer.Dispose();
                    //    graphicsForTextRenderer = null;
                    this.pdfFont.clear();
                    this.pdfFont = null;
                    this.bidi.clear();
                    this.bidi = null;
                    //    imageCache.Clear();
                };
                StiPdfExportService.regexEscape = new RegExp("([{}\(\)\^$&.\*\?\/\+\|\[\\\\]|\]|\-)", "g");
                return StiPdfExportService;
            }(Export.StiExportService));
            Export.StiPdfExportService = StiPdfExportService;
        })(Export = Report.Export || (Report.Export = {}));
    })(Report = Stimulsoft.Report || (Stimulsoft.Report = {}));
})(Stimulsoft || (Stimulsoft = {}));


var Stimulsoft;
(function (Stimulsoft) {
    var Report;
    (function (Report) {
        var Export;
        (function (Export) {
            var StringBuilder = Stimulsoft.System.Text.StringBuilder;
            var Font = Stimulsoft.System.Drawing.Font;
            var Hashtable = Stimulsoft.System.Collections.Hashtable;
            var MemoryStream = Stimulsoft.System.IO.MemoryStream;
            var FontStyle = Stimulsoft.System.Drawing.FontStyle;
            var PdfFontInfo = /** @class */ (function () {
                function PdfFontInfo() {
                }
                return PdfFontInfo;
            }());
            Export.PdfFontInfo = PdfFontInfo;
            var pfontInfo = /** @class */ (function () {
                function pfontInfo() {
                }
                return pfontInfo;
            }());
            Export.pfontInfo = pfontInfo;
            var TableDirectoryItem = /** @class */ (function () {
                function TableDirectoryItem() {
                    this.TagString = null;
                    this.Tag = 0;
                    this.CheckSum = 0;
                    this.Offset = 0;
                    this.Length = 0;
                    this.NewOffset = 0;
                    this.NewLength = 0;
                    this.Required = false;
                    this.NewTable = null;
                }
                return TableDirectoryItem;
            }());
            var TtfInfo = /** @class */ (function () {
                function TtfInfo() {
                    this.HeaderOffset = 0;
                    this.NumTables = 0;
                    this.NumTablesRequired = 0;
                    this.SfntVersion = 0;
                    this.Tables = null;
                    this.HeadCheckSumOffset = 0;
                    this.NumGlyphs = 0;
                    this.IndexToLocFormat = 0;
                    this.IndexLocaTable = 0;
                    this.IndexGlyfTable = 0;
                    this.IndexCmapTable = 0;
                    this.FontName = null;
                    this.HeaderOffset = 0;
                    this.NumTables = 0;
                    this.NumTablesRequired = 0;
                    this.SfntVersion = 0;
                    this.Tables = null;
                    this.HeadCheckSumOffset = 0;
                    this.NumGlyphs = 0;
                    this.IndexToLocFormat = 0;
                    this.IndexLocaTable = 0;
                    this.IndexGlyfTable = 0;
                    this.FontName = new Hashtable();
                }
                return TtfInfo;
            }());
            var PdfFonts = /** @class */ (function (_super) {
                __extends(PdfFonts, _super);
                function PdfFonts() {
                    var _this = _super.call(this) || this;
                  
                    _this.standardFontQuantity = 12;
                    _this.standardFontNumWidths = 310;
                    _this.standardFontNumChars = 3680 + 189;
                    // Fields
                    _this.firstMappedSymbol = 64;
                    _this.factor = 1;
                    // max symbols for output. StandartMode=255, UnicodeMode=32767
                    _this.maxSymbols = 32767;
                    _this.useUnicode = true;
                    //            private OUTLINETEXTMETRIC otm; // = new OUTLINETEXTMETRIC();
                    _this.WIDTHS = null;
                    _this.fonts = null;
                    _this.UnicodeMapsList = null;
                    _this.GlyphMapsList = null;
                    _this.standardPdfFonts = true;
                    _this.fontsInfoStore = null;
                    //            private static Hashtable FontsCache = new Hashtable();
                    _this.family_Helvetica = ["Arial",
                        "Arial Black",
                        "Arial Narrow",
                        "Century Gothic",
                        "Comic Sans MS",
                        "Impact",
                        "Microsoft Sans Serif",
                        "Tahoma",
                        "Verdana"];
                    _this.family_Courier = ["Courier New",
                        "Lucida Console"];
                    _this.family_Times_Roman = ["Book Antiqua",
                        "Bookman Old Style",
                        "Garamond",
                        "Georgia",
                        "Times New Roman"];
                    _this.family_Symbol = ["Symbol"];
                    _this.family_ZapfDingbats = ["Wingdings 2"];
                    _this.PdfFontName = ["Helvetica",
                        "Helvetica-Bold",
                        "Helvetica-Oblique",
                        "Helvetica-BoldOblique",
                        "Times-Roman",
                        "Times-Bold",
                        "Times-Italic",
                        "Times-BoldItalic",
                        "Courier",
                        "Courier-Bold",
                        "Courier-Oblique",
                        "Courier-BoldOblique",
                        "Symbol",
                        "ZapfDingbats"];
                    _this._currentFont = -1;
                    //          #region StoreGlyphsInMap
                    //          void StoreGlyphsInMap(StringBuilder sb)
                    //          {
                    //              if ((sb.Length > 0) && (currentFont != -1))
                    //              {
                    //                  ushort[] map = (ushort[])GlyphMapsList[currentFont];
                    //                  for (int indexChar = 0; indexChar < sb.Length; indexChar++)
                    //                  {
                    //                      map[(ushort)sb[indexChar]] = 1;
                    //                  }
                    //                  map[0xffff] = 1;
                    //              }
                    //          }
                    //          #endregion
                    //#region OpenType fonts
                    _this.TtfHeaderSize = 12;
                    //#region Constants for the OpenType font flags field
                    _this.ARG_1_AND_2_ARE_WORDS = 0x0001;
                    _this.ARGS_ARE_XY_VALUES = 0x0002;
                    _this.ROUND_XY_TO_GRID = 0x0004;
                    _this.WE_HAVE_A_SCALE = 0x0008;
                    _this.MORE_COMPONENTS = 0x0020;
                    _this.WE_HAVE_AN_X_AND_Y_SCALE = 0x0040;
                    _this.WE_HAVE_A_TWO_BY_TWO = 0x0080;
                    _this.WE_HAVE_INSTRUCTIONS = 0x0100;
                    _this.USE_MY_METRICS = 0x0200;
                    _this.OVERLAP_COMPOUND = 0x0400;
                    _this.SCALED_COMPONENT_OFFSET = 0x0800;
                    _this.UNSCALED_COMPONENT_OFFSET = 0x1000;
                    //#endregion
                    //#region tables names
                    _this.TablesNames = [
                        "head",
                        "hhea",
                        "hmtx",
                        "maxp",
                        "cmap",
                        "OS/2",
                        "post",
                        "cvt ",
                        "fpgm",
                        "glyf",
                        "loca",
                        "prep",
                        "name" // this table required for Windows
                    ];
                    _this.fontList = new Array();
                    _this.UnicodeMapsList = new Array();
                    _this.GlyphMapsList = new Array();
                    // InitStandardFontWidths();
                    // InitStandardFontInfo();
                    _this.fontsInfoStore = new FontsInfoStore();
                    return _this;
                }
                
                PdfFonts.prototype.getFontMetrics = function (font, currentFontInfo, glyphMap, report) {
                    this.WIDTHS = Array.create(Number, this.maxSymbols + 1);
                    if (font == null)
                        return;
                    var tempFont = new Font(font.name, 1024, font.style, Stimulsoft.System.Drawing.GraphicsUnit.Pixel);
                    // get symbols widths
                    Array.copy(currentFontInfo.UnicodeMapBack, 0, this.WIDTHS, currentFontInfo.MappedSymbolsCount);
                    var size = Stimulsoft.System.Drawing.Graphics.measureChars(this.WIDTHS, currentFontInfo.MappedSymbolsCount, tempFont);
                    var symHeight = size.height;
                    var lineHeight = size.width;
                    currentFontInfo.CH = 0; // Math.round2(otm.otmsCapEmHeight * this.factor);
                    // currentFontInfo.XH = 0;
                    // currentFontInfo.ASC = Math.round2(otm.otmAscent * this.factor);
                    // currentFontInfo.DESC = Math.round2(otm.otmDescent * this.factor);
                    currentFontInfo.tmASC = Math.round2(symHeight * 0.8 * this.factor);
                    currentFontInfo.tmDESC = Math.round2(symHeight * 0.2 * this.factor);
                    currentFontInfo.tmExternal = Math.round2((lineHeight - symHeight) * this.factor);
                    currentFontInfo.LLX = 0; // Math.round2(otm.otmrcFontBox.left * this.factor);
                    currentFontInfo.LLY = 0; // Math.round2(otm.otmrcFontBox.bottom * this.factor);
                    currentFontInfo.URX = 0; // Math.round2(otm.otmrcFontBox.right * this.factor);
                    currentFontInfo.URY = 0; // Math.round2(otm.otmrcFontBox.top * this.factor);
                    currentFontInfo.StemV = 0; // Math.round2(0 * this.factor);
                    currentFontInfo.ItalicAngle = 0; // Math.round2((float)otm.otmItalicAngle / 10);
                    // currentFontInfo.LineGap = Math.round2(otm.otmLineGap * this.factor);
                    // currentFontInfo.MacAscend = Math.round2(otm.otmMacAscent * this.factor);
                    // currentFontInfo.MacDescend = Math.round2(otm.otmMacDescent * this.factor);
                    // currentFontInfo.MacLineGap = Math.round2(otm.otmMacLineGap * this.factor);
                    // currentFontInfo.NtmFlags = 0;
                    currentFontInfo.UnderscoreSize = Math.round2(symHeight * (font.bold ? 0.08 : 0.06) * this.factor);
                    currentFontInfo.UnderscorePosition = Math.round2(-symHeight * 0.1 * this.factor);
                    currentFontInfo.StrikeoutSize = Math.round2(symHeight * 0.045 * this.factor);
                    currentFontInfo.StrikeoutPosition = Math.round2(symHeight * 0.25 * this.factor);
                    for (var index = 0; index < currentFontInfo.MappedSymbolsCount; index++) {
                        this.WIDTHS[index] = Math.round2(this.WIDTHS[index] * this.factor, 0);
                    }
                    //#region Get glyphs list
                    // if (this.useUnicode) {
                    var fontData = Stimulsoft.Base.StiFontCollection.getBinFont(font.name, font.style);
                    var buff = fontData != null ? fontData.data : null;
                    if (buff == null) {
                        var isBold = (font.style & FontStyle.Bold) > 0;
                        var isItalic = (font.style & FontStyle.Italic) > 0;
                        if (isBold && isItalic) {
                            fontData = Stimulsoft.Base.StiFontCollection.getBinFont(font.name, FontStyle.Italic);
                            if (fontData != null && fontData.data != null) {
                                buff = fontData.data;
                                this.NeedSyntBold = true;
                            }
                            else {
                                fontData = Stimulsoft.Base.StiFontCollection.getBinFont(font.name, FontStyle.Bold);
                                if (fontData != null && fontData.data != null) {
                                    buff = fontData.data;
                                    this.NeedSyntItalic = true;
                                }
                                else {
                                    fontData = Stimulsoft.Base.StiFontCollection.getBinFont(font.name, FontStyle.Regular);
                                    if (fontData != null && fontData.data != null) {
                                        buff = fontData.data;
                                        this.NeedSyntItalic = true;
                                        this.NeedSyntBold = true;
                                    }
                                }
                            }
                        }
                        else {
                            if (isBold) {
                                fontData = Stimulsoft.Base.StiFontCollection.getBinFont(font.name, FontStyle.Regular);
                                if (fontData != null && fontData.data != null) {
                                    buff = fontData.data;
                                    this.NeedSyntBold = true;
                                }
                            }
                            if (isItalic) {
                                fontData = Stimulsoft.Base.StiFontCollection.getBinFont(font.name, FontStyle.Regular);
                                if (fontData != null && fontData.data != null) {
                                    buff = fontData.data;
                                    this.NeedSyntItalic = true;
                                }
                            }
                        }
                    }
                    if (buff == null) {
                        var resource = report.dictionary.resources.getByName(font.name);
                        if (resource == null)
                            resource = report.dictionary.resources.getByAlias(font.name);
                        if (resource != null && resource.content != null && resource.content.length > 0) {
                            buff = new Uint8Array(resource.content);
                            this.NeedSyntBold = true;
                            this.NeedSyntItalic = true;
                        }
                    }
                    if (buff != null && buff.sti.is(Uint8Array) && (buff.byteLength > 0)) {
                        var cmap = this.getCharToGlyphTable(buff, font.name);
                        if (cmap != null) {
                            // fix for some fonts
                            var offset = 0;
                            if (font.name == "Wingdings" || font.name == "Wingdings 2" || font.name == "Wingdings 3")
                                offset = 0xF000;
                            for (var index = 0; index < currentFontInfo.MappedSymbolsCount; index++) {
                                var charCode = currentFontInfo.UnicodeMapBack[index];
                                if ((charCode >= 128) && (charCode <= 255)) {
                                    charCode += offset;
                                }
                                currentFontInfo.GlyphList[index] = cmap[charCode];
                            }
                        }
                    }
                    currentFontInfo.NeedSyntBold = this.NeedSyntBold;
                    currentFontInfo.NeedSyntItalic = this.NeedSyntItalic;
                    // }
                    //#endregion
                };
                Object.defineProperty(PdfFonts.prototype, "currentFont", {
                    get: function () {
                        return this._currentFont;
                    },
                    set: function (value) {
                        if (this._currentFont != value) {
                            this._currentFont = value;
                            if ((this.fonts != null) && (this.fonts.length > 0)) {
                                this.Widths = this.fonts[this._currentFont].Widths;
                                this.CH = this.fonts[this._currentFont].CH;
                                this.XH = this.fonts[this._currentFont].XH;
                                this.ASC = this.fonts[this._currentFont].ASC;
                                this.DESC = this.fonts[this._currentFont].DESC;
                                this.tmASC = this.fonts[this._currentFont].tmASC;
                                this.tmDESC = this.fonts[this._currentFont].tmDESC;
                                this.tmExternal = this.fonts[this._currentFont].tmExternal;
                                this.MacAscend = this.fonts[this._currentFont].MacAscend;
                                this.MacDescend = this.fonts[this._currentFont].MacDescend;
                                this.MacLineGap = this.fonts[this._currentFont].MacLineGap;
                                this.LLX = this.fonts[this._currentFont].LLX;
                                this.LLY = this.fonts[this._currentFont].LLY;
                                this.URX = this.fonts[this._currentFont].URX;
                                this.URY = this.fonts[this._currentFont].URY;
                                this.StemV = this.fonts[this._currentFont].StemV;
                                this.ItalicAngle = this.fonts[this._currentFont].ItalicAngle;
                                this.LineGap = this.fonts[this._currentFont].LineGap;
                                this.NtmFlags = this.fonts[this._currentFont].NtmFlags;
                                this.UnderscoreSize = this.fonts[this._currentFont].UnderscoreSize;
                                this.UnderscorePosition = this.fonts[this._currentFont].UnderscorePosition;
                                this.StrikeoutSize = this.fonts[this._currentFont].StrikeoutSize;
                                this.StrikeoutPosition = this.fonts[this._currentFont].StrikeoutPosition;
                                this.UnicodeMap = this.fonts[this._currentFont].UnicodeMap;
                                this.UnicodeMapBack = this.fonts[this._currentFont].UnicodeMapBack;
                                this.GlyphList = this.fonts[this._currentFont].GlyphList;
                                this.GlyphBackList = this.fonts[this._currentFont].GlyphBackList;
                                this.GlyphRtfList = this.fonts[this._currentFont].GlyphRtfList;
                                this.SymsToPDF = this.fonts[this._currentFont].SymsToPDF;
                                this.CharPdfNames = this.fonts[this._currentFont].CharPdfNames;
                                this.MappedSymbolsCount = this.fonts[this._currentFont].MappedSymbolsCount;
                                this.NeedSyntBold = this.fonts[this._currentFont].NeedSyntBold;
                                this.NeedSyntItalic = this.fonts[this._currentFont].NeedSyntItalic;
                                this.GlyphWidths = this.fonts[this._currentFont].GlyphWidths;
                                this.ChildFontsMap = this.fonts[this._currentFont].ChildFontsMap;
                            }
                        }
                    },
                    enumerable: true,
                    configurable: true
                });
                PdfFonts.prototype.InitFontsData = function (report) {
                    // make additional fonts for standard mode
                    if (!this.useUnicode) {
                        var fontsCount = this.fontList.length;
                        for (var indexFont = 0; indexFont < fontsCount; indexFont++) {
                            var map = this.UnicodeMapsList[indexFont];
                            var mapSymbol = this.firstMappedSymbol;
                            for (var indexChar = this.firstMappedSymbol; indexChar < 65536; indexChar++) {
                                if (map[indexChar] > 0)
                                    mapSymbol++;
                            }
                            if (mapSymbol > 255) {
                                // add fonts
                                var currFont = this.fontList[indexFont];
                                var newMap = null;
                                var fontsMap = Array.create(Number, 65536);
                                var currentFontNumber = this.fontList.length;
                                for (var indexChar = 0; indexChar < this.firstMappedSymbol; indexChar++)
                                    fontsMap[indexChar] = currentFontNumber;
                                var needAddNewFontInfo = true;
                                mapSymbol = this.firstMappedSymbol;
                                for (var indexChar = this.firstMappedSymbol; indexChar < 65536; indexChar++) {
                                    if (needAddNewFontInfo) {
                                        var fi = new pfontInfo();
                                        fi.Name = currFont.Name;
                                        fi.PdfName = currFont.PdfName;
                                        fi.Bold = currFont.Bold;
                                        fi.Italic = currFont.Italic;
                                        fi.Number = currFont.Number;
                                        fi.Font = currFont.Font;
                                        fi.ParentFontNumber = indexFont;
                                        this.fontList.add(fi);
                                        newMap = Array.create(Number, 65536);
                                        Array.copy(map, 0, newMap, 64);
                                        this.UnicodeMapsList.add(newMap);
                                        this.GlyphMapsList.add(Array.create(Number, 65536));
                                        currentFontNumber = this.fontList.length - 1;
                                        mapSymbol = this.firstMappedSymbol;
                                        needAddNewFontInfo = false;
                                    }
                                    if (map[indexChar] > 0) {
                                        newMap[indexChar] = 1;
                                        fontsMap[indexChar] = currentFontNumber;
                                        mapSymbol++;
                                        if (mapSymbol == 254)
                                            needAddNewFontInfo = true;
                                    }
                                }
                                currFont.ChildFontsMap = fontsMap;
                                this.fontList[indexFont] = currFont;
                            }
                        }
                    }
                    // init fonts array
                    this.fonts = Array.create(PdfFontInfo, this.fontList.length);
                    for (var indexFont = 0; indexFont < this.fontList.length; indexFont++) {
                        this.fonts[indexFont] = new PdfFontInfo();
                        var currentFontInfo = this.fonts[indexFont];
                        currentFontInfo.UnicodeMap = this.UnicodeMapsList[indexFont];
                        currentFontInfo.UnicodeMapBack = Array.create(Number, this.maxSymbols + 1);
                        // prepare GlyphBackList, GlyphRtfList tables and store known symbols in UnicodeMap
                        var tempGlyphMap = this.GlyphMapsList[indexFont];
                        var tempBackMap = Array.create(Number, 65536);
                        if (tempGlyphMap[65535] != 0) {
                            // pfontInfo tmpfinf = (pfontInfo)fontList[indexFont];
                            // currentFontInfo.GlyphBackList = MakeGlyphBackMap(tmpfinf.Font);
                            // int currentGlyph = 0;
                            // for (int index = 0; index < 65535; index++)
                            // {
                            //  if (tempGlyphMap[index] != 0)
                            //  {
                            //      currentFontInfo.UnicodeMap[currentFontInfo.GlyphBackList[index]] = 1;
                            //      tempBackMap[currentGlyph] = (ushort)index;
                            //      currentGlyph++;
                            //  }
                            // }
                            // currentFontInfo.GlyphRtfList = new ushort[currentGlyph];
                            // Array.Copy(tempBackMap, 0, currentFontInfo.GlyphRtfList, 0, currentGlyph);
                        }
                        // prepare UnicodeMap table
                        var mappedSymbol = this.firstMappedSymbol;
                        for (var indexSymbol = this.firstMappedSymbol; indexSymbol < 65536; indexSymbol++) {
                            if (currentFontInfo.UnicodeMap[indexSymbol] != 0) {
                                currentFontInfo.UnicodeMap[indexSymbol] = mappedSymbol;
                                currentFontInfo.UnicodeMapBack[mappedSymbol] = indexSymbol;
                                mappedSymbol++;
                                if (mappedSymbol > this.maxSymbols)
                                    mappedSymbol = this.maxSymbols;
                                if (!this.useUnicode && mappedSymbol == 92) {
                                    currentFontInfo.UnicodeMapBack[mappedSymbol] = indexSymbol;
                                    mappedSymbol++;
                                }
                            }
                        }
                        var tempIndexSymbol = 0x2022; // bullet
                        currentFontInfo.UnicodeMap[tempIndexSymbol] = mappedSymbol;
                        currentFontInfo.UnicodeMapBack[mappedSymbol] = tempIndexSymbol;
                        mappedSymbol++;
                        currentFontInfo.MappedSymbolsCount = mappedSymbol;
                        for (var indexSymbol = 0; indexSymbol < this.firstMappedSymbol; indexSymbol++) {
                            currentFontInfo.UnicodeMap[indexSymbol] = indexSymbol;
                            currentFontInfo.UnicodeMapBack[indexSymbol] = indexSymbol;
                        }
                        // init SymsToPDF array and char names
                        currentFontInfo.CharPdfNames = Array.create(String, mappedSymbol);
                        currentFontInfo.SymsToPDF = Array.create(Number, mappedSymbol);
                        for (var indexTemp = 32; indexTemp < currentFontInfo.MappedSymbolsCount; indexTemp++) {
                            var offset = -1;
                            for (var indexOffset = 0; indexOffset < this.standardFontNumWidths; indexOffset++) {
                                // if (currentFontInfo.UnicodeMapBack[indexTemp] == StandardFontWidths[indexOffset, 0])
                                // {
                                //  offset = indexOffset;
                                //  break;
                                // }
                            }
                            currentFontInfo.SymsToPDF[indexTemp] = offset;
                            var st = Export.StiPdfResources.standardFontCharsNames[currentFontInfo.UnicodeMapBack[indexTemp]];
                            if (st == null) {
                                st = "uni" + currentFontInfo.UnicodeMapBack[indexTemp].toString(16).toUpperCase().sti.padLeft(4, "0");
                            }
                            currentFontInfo.CharPdfNames[indexTemp] = st;
                        }
                        // fill array with glyph indicies and width data
                        currentFontInfo.GlyphList = Array.create(Number, mappedSymbol);
                        // get font info from GDI
                        var tmpfi = this.fontList[indexFont];
                        this.fonts[indexFont].Widths = Array.create(Number, mappedSymbol);
                        this.getFontMetrics(tmpfi.Font, currentFontInfo, tempGlyphMap, report);
                        for (var tempIndex = 0; tempIndex < mappedSymbol - 32; tempIndex++) {
                            this.fonts[indexFont].Widths[tempIndex] = this.WIDTHS[32 + tempIndex];
                        }
                        if (this.standardPdfFonts == true) {
                            //// replace with standard PDF fonts info
                            // for (int tempIndex = 32; tempIndex < currentFontInfo.MappedSymbolsCount; tempIndex++)
                            // {
                            //  if (fonts[indexFont].SymsToPDF[tempIndex] != -1)
                            //  {
                            //      fonts[indexFont].Widths[tempIndex - 32] =
                            //          StandardFontWidths[fonts[indexFont].SymsToPDF[tempIndex], tmpfi.Number + 1];
                            //  }
                            // }
                            // fonts[indexFont].ItalicAngle  = StandardFontInfo[0, tmpfi.Number] / 10;
                            // fonts[indexFont].LLX  = StandardFontInfo[1, tmpfi.Number];
                            // fonts[indexFont].LLY  = StandardFontInfo[2, tmpfi.Number];
                            // fonts[indexFont].URX  = StandardFontInfo[3, tmpfi.Number];
                            // fonts[indexFont].URY  = StandardFontInfo[4, tmpfi.Number];
                            // fonts[indexFont].CH   = StandardFontInfo[5, tmpfi.Number];
                            // fonts[indexFont].XH   = StandardFontInfo[6, tmpfi.Number];
                            // fonts[indexFont].ASC  = StandardFontInfo[7, tmpfi.Number];
                            // fonts[indexFont].DESC = StandardFontInfo[8, tmpfi.Number];
                            // fonts[indexFont].StemV = 0;
                        }
                        if ((this.fontList[indexFont]).ChildFontsMap != null) {
                            currentFontInfo.MappedSymbolsCount = 255;
                            currentFontInfo.ChildFontsMap = (this.fontList[indexFont]).ChildFontsMap;
                        }
                    }
                    this._currentFont = -1;
                    this.currentFont = 0;
                };
                PdfFonts.prototype.getFontNumber = function (incomingFont) {
                    var fontNumber = -1;
                    // check fonts table for font
                    if (this.fontList.length > 0) {
                        for (var index = 0; index < this.fontList.length; index++) {
                            var tmpfi = this.fontList[index];
                            if ((tmpfi.Name == incomingFont.name) &&
                                (tmpfi.Bold == incomingFont.bold) &&
                                (tmpfi.Italic == incomingFont.italic)) {
                                fontNumber = index;
                                break;
                            }
                        }
                    }
                    if (fontNumber == -1) {
                        // add to fonts table
                        var fi = new pfontInfo();
                        fi.Name = incomingFont.name;
                        fi.Bold = incomingFont.bold;
                        fi.Italic = incomingFont.italic;
                        fi.Font = incomingFont;
                        fi.ParentFontNumber = -1;
                        fontNumber = 0;
                        // This font will be use by default
                        for (var _i = 0, _a = this.family_Helvetica; _i < _a.length; _i++) {
                            var st = _a[_i];
                            if (fi.Name == st)
                                fontNumber = 0;
                        }
                        for (var _b = 0, _c = this.family_Times_Roman; _b < _c.length; _b++) {
                            var st = _c[_b];
                            if (fi.Name == st)
                                fontNumber = 4;
                        }
                        for (var _d = 0, _e = this.family_Courier; _d < _e.length; _d++) {
                            var st = _e[_d];
                            if (fi.Name == st)
                                fontNumber = 8;
                        }
                        if (fontNumber < 12) {
                            if (fi.Bold == true)
                                fontNumber += 1;
                            if (fi.Italic == true)
                                fontNumber += 2;
                        }
                        fi.Number = fontNumber;
                        fi.PdfName = this.PdfFontName[fontNumber];
                        this.fontList.add(fi);
                        fontNumber = this.fontList.length - 1;
                        this.UnicodeMapsList.add(Array.create(Number, 65536));
                        this.GlyphMapsList.add(Array.create(Number, 65536));
                    }
                    this.currentFont = fontNumber;
                    return fontNumber;
                };
                PdfFonts.prototype.storeUnicodeSymbolsInMap = function (sb) {
                    var st = sb.toString();
                    if ((st.length > 0) && (this.currentFont != -1)) {
                        var map = this.UnicodeMapsList[this.currentFont];
                        for (var indexChar = 0; indexChar < st.length; indexChar++) {
                            map[st.charCodeAt(indexChar)] = 1;
                        }
                    }
                };
                PdfFonts.prototype.getCharToGlyphTable = function (buff, fontName) {
                    var ttf = this.scanFontFile(buff, fontName);
                    if (ttf != null) {
                        return this.getCmapTable(buff, ttf);
                    }
                    return null;
                };
                //#region reduce font size
                // public void ReduceFontSize(ref byte[] buff, string fontName, bool remakeGlyphTable)
                PdfFonts.prototype.reduceFontSize = function (buff, fontName, remakeGlyphTable) {
                    var ttf = this.scanFontFile(buff, fontName);
                    var outputStream = null;
                    if (ttf != null) {
                        if (remakeGlyphTable) {
                            //#region remake tables
                            //#region prepare array
                            var glyphNeeds = Array.create(Boolean, ttf.NumGlyphs);
                            var glyphNeedsScan = Array.create(Boolean, ttf.NumGlyphs);
                            for (var indexGlyph = 0; indexGlyph < this.GlyphList.length; indexGlyph++) {
                                var glyphNumber = this.GlyphList[indexGlyph];
                                if (glyphNumber < ttf.NumGlyphs) {
                                    glyphNeeds[glyphNumber] = true;
                                    glyphNeedsScan[glyphNumber] = true;
                                }
                            }
                            // if (GlyphRtfList != null) {
                            //    for (int indexGlyph = 0; indexGlyph < GlyphRtfList.Length; indexGlyph++)
                            //    {
                            //        ushort glyphNumber = GlyphRtfList[indexGlyph];
                            //        if (glyphNumber < ttf.NumGlyphs) {
                            //            glyphNeeds[glyphNumber] = true;
                            //            glyphNeedsScan[glyphNumber] = true;
                            //        }
                            //    }
                            // }
                            glyphNeeds[0] = true;
                            glyphNeeds[1] = true;
                            glyphNeeds[2] = true;
                            glyphNeeds[3] = true;
                            glyphNeedsScan[0] = true;
                            glyphNeedsScan[1] = true;
                            glyphNeedsScan[2] = true;
                            glyphNeedsScan[3] = true;
                            //#endregion
                            var offsetLocaTable = ttf.Tables[ttf.IndexLocaTable].Offset;
                            var offsetGlyfTable = ttf.Tables[ttf.IndexGlyfTable].Offset;
                            //#region scan glyf table for composite glyph
                            var needScan = true;
                            while (needScan) {
                                needScan = false;
                                for (var indexGlyph = 0; indexGlyph < ttf.NumGlyphs; indexGlyph++) {
                                    if (glyphNeedsScan[indexGlyph] == true) {
                                        glyphNeedsScan[indexGlyph] = false;
                                        var locaOffsetScan = offsetLocaTable + indexGlyph * (ttf.IndexToLocFormat == 1 ? 4 : 2);
                                        var offsetGlyf = 0;
                                        if (ttf.IndexToLocFormat == 1) {
                                            offsetGlyf = this.GetUInt32(buff, locaOffsetScan);
                                        }
                                        else {
                                            offsetGlyf = 2 * this.GetUInt16(buff, locaOffsetScan);
                                        }
                                        offsetGlyf += offsetGlyfTable;
                                        if (this.GetInt16(buff, offsetGlyf) == -1) // composite glyph
                                         {
                                            needScan = true;
                                            //#region scan composite glyph
                                            offsetGlyf += 10; // glyf header length
                                            var flags = 0;
                                            do {
                                                flags = this.GetUInt16(buff, offsetGlyf);
                                                var glyphIndex = this.GetUInt16(buff, offsetGlyf + 2);
                                                if (glyphIndex < ttf.NumGlyphs) {
                                                    glyphNeeds[glyphIndex] = true;
                                                    glyphNeedsScan[glyphIndex] = true;
                                                }
                                                offsetGlyf += 4;
                                                if ((flags & this.ARG_1_AND_2_ARE_WORDS) > 0) {
                                                    offsetGlyf += 2; // argument1;
                                                    offsetGlyf += 2; // argument2;
                                                }
                                                else {
                                                    offsetGlyf += 2; // argument 1 and 2;
                                                }
                                                if ((flags & this.WE_HAVE_A_SCALE) > 0) {
                                                    offsetGlyf += 2; // Format 2.14
                                                }
                                                else {
                                                    if ((flags & this.WE_HAVE_AN_X_AND_Y_SCALE) > 0) {
                                                        offsetGlyf += 2; // Format 2.14
                                                        offsetGlyf += 2; // Format 2.14
                                                    }
                                                    else {
                                                        if ((flags & this.WE_HAVE_A_TWO_BY_TWO) > 0) {
                                                            offsetGlyf += 2; // Format 2.14
                                                            offsetGlyf += 2; // Format 2.14
                                                            offsetGlyf += 2; // Format 2.14
                                                            offsetGlyf += 2; // Format 2.14
                                                        }
                                                    }
                                                }
                                            } while ((flags & this.MORE_COMPONENTS) > 0);
                                            //#endregion
                                        }
                                    }
                                }
                            }
                            //#endregion
                            //#region remake glyf table
                            // first pass - calculate new length
                            var newLength = 0;
                            var locaOffset = offsetLocaTable;
                            for (var indexGlyph = 0; indexGlyph < ttf.NumGlyphs; indexGlyph++) {
                                var offsetBegin = 0;
                                var offsetEnd = 0;
                                if (ttf.IndexToLocFormat == 1) {
                                    offsetBegin = this.GetUInt32(buff, locaOffset);
                                    offsetEnd = this.GetUInt32(buff, locaOffset + 4);
                                    locaOffset += 4;
                                }
                                else {
                                    offsetBegin = 2 * this.GetUInt16(buff, locaOffset);
                                    offsetEnd = 2 * this.GetUInt16(buff, locaOffset + 2);
                                    locaOffset += 2;
                                }
                                if (glyphNeeds[indexGlyph]) {
                                    newLength += offsetEnd - offsetBegin;
                                }
                            }
                            // second pass - create new table
                            var newGlyfTable = new Uint8Array(newLength + 4);
                            // this.copyUint8Array(buff, offsetGlyfTable + ttf.Tables[ttf.IndexGlyfTable].Length, newGlyfTable, newLength, 4);
                            var newLocaTable = new Uint8Array(ttf.Tables[ttf.IndexLocaTable].Length + 4);
                            // this.copyUint8Array(buff, offsetLocaTable + ttf.Tables[ttf.IndexLocaTable].Length, newLocaTable, ttf.Tables[ttf.IndexLocaTable].Length, 4);
                            var currentGlyfPos = 0;
                            locaOffset = offsetLocaTable;
                            var locaOffset2 = 0;
                            for (var indexGlyph = 0; indexGlyph < ttf.NumGlyphs; indexGlyph++) {
                                var offsetBegin = 0;
                                var offsetEnd = 0;
                                if (ttf.IndexToLocFormat == 1) {
                                    offsetBegin = this.GetUInt32(buff, locaOffset);
                                    offsetEnd = this.GetUInt32(buff, locaOffset + 4);
                                    locaOffset += 4;
                                }
                                else {
                                    offsetBegin = 2 * this.GetUInt16(buff, locaOffset);
                                    offsetEnd = 2 * this.GetUInt16(buff, locaOffset + 2);
                                    locaOffset += 2;
                                }
                                var lengthGlyf = offsetEnd - offsetBegin;
                                if (glyphNeeds[indexGlyph] == true) {
                                    for (var indexPos = 0; indexPos < lengthGlyf; indexPos++) {
                                        newGlyfTable[currentGlyfPos + indexPos] = buff[offsetGlyfTable + offsetBegin + indexPos];
                                    }
                                }
                                else {
                                    lengthGlyf = 0;
                                }
                                if (ttf.IndexToLocFormat == 0) {
                                    this.SetUInt16(newLocaTable, locaOffset2, (currentGlyfPos / 2));
                                }
                                else {
                                    this.SetUInt32(newLocaTable, locaOffset2, currentGlyfPos);
                                }
                                currentGlyfPos += lengthGlyf;
                                locaOffset2 += (ttf.IndexToLocFormat == 1) ? 4 : 2;
                            }
                            if (ttf.IndexToLocFormat == 0) {
                                this.SetUInt16(newLocaTable, locaOffset2, (currentGlyfPos / 2));
                            }
                            else {
                                this.SetUInt32(newLocaTable, locaOffset2, currentGlyfPos);
                            }
                            ttf.Tables[ttf.IndexGlyfTable].NewLength = currentGlyfPos;
                            ttf.Tables[ttf.IndexGlyfTable].NewTable = newGlyfTable;
                            ttf.Tables[ttf.IndexLocaTable].NewTable = newLocaTable;
                            // for (int indexG = (int)currentGlyfPos; indexG < ttf.Tables[ttf.IndexGlyfTable].Length; indexG ++)
                            // {
                            //    buff[offsetGlyfTable + indexG] = 0;
                            // }
                            //#endregion
                            //#endregion
                        }
                        var newHeader = new Uint8Array(this.TtfHeaderSize + ttf.NumTablesRequired * 16);
                        this.copyUint8Array(buff, ttf.HeaderOffset, newHeader, 0, newHeader.length);
                        //#region make new offset table
                        var maximumPower = 1;
                        while (2 << (maximumPower - 1) <= ttf.NumTablesRequired) {
                            maximumPower++;
                        }
                        maximumPower--;
                        var searchRange = (2 << (maximumPower - 1)) * 16;
                        var entrySelector = maximumPower;
                        var rangeShift = ttf.NumTablesRequired * 16 - searchRange;
                        this.SetUInt16(newHeader, 4, ttf.NumTablesRequired);
                        this.SetUInt16(newHeader, 6, searchRange);
                        this.SetUInt16(newHeader, 8, entrySelector);
                        this.SetUInt16(newHeader, 10, rangeShift);
                        //#endregion
                        //#region make new table info
                        // uint globalCheckSum = 0;
                        var currentTable = 0;
                        var currentPos = (this.TtfHeaderSize + ttf.NumTablesRequired * 16);
                        for (var indexTable = 0; indexTable < ttf.NumTables; indexTable++) {
                            if (ttf.Tables[indexTable].Required) {
                                ttf.Tables[indexTable].NewOffset = currentPos;
                                currentPos += ttf.Tables[indexTable].NewLength;
                                var remainder = currentPos % 4;
                                if (remainder > 0) {
                                    currentPos += 4 - remainder;
                                }
                                // calculate checksum for this table
                                // uint checkSum = 0;
                                // uint lengthTable = (ttf.Tables[indexTable].NewLength + (remainder > 0 ? 4 - remainder : 0)) / 4;
                                // byte[] buff2 = buff;
                                // int offsetCheck = (int)ttf.Tables[indexTable].Offset;
                                // if (ttf.Tables[indexTable].NewTable != null)
                                // {
                                //    buff2 = ttf.Tables[indexTable].NewTable;
                                //    offsetCheck = 0;
                                // }
                                // for (int indexLen = 0; indexLen < lengthTable; indexLen++)
                                // {
                                //    checkSum += GetUInt32(buff2, offsetCheck);
                                //    offsetCheck += 4;
                                // }
                                // ttf.Tables[indexTable].CheckSum = checkSum;
                                // globalCheckSum += checkSum;
                                var pos = (this.TtfHeaderSize + currentTable * 16);
                                this.SetUInt32(newHeader, pos, ttf.Tables[indexTable].Tag);
                                this.SetUInt32(newHeader, pos + 4, ttf.Tables[indexTable].CheckSum);
                                this.SetUInt32(newHeader, pos + 8, ttf.Tables[indexTable].NewOffset);
                                this.SetUInt32(newHeader, pos + 12, ttf.Tables[indexTable].NewLength);
                                currentTable++;
                            }
                        }
                        //#endregion
                        //#region correct global checksum
                        // for (int indexSum = 0; indexSum < (ttf.HeaderOffset + TtfHeaderSize + ttf.NumTablesRequired * 16) / 4; indexSum ++)
                        // {
                        //    globalCheckSum += GetUInt32(buff, (int)(indexSum * 4));
                        // }
                        // globalCheckSum = 0xB1B0AFBA - globalCheckSum;
                        // SetUInt32(newHeader, ttf.HeadCheckSumOffset, globalCheckSum);
                        //#endregion
                        //#region write new font
                        outputStream = new MemoryStream();
                        outputStream.writeBytes(newHeader, 0, newHeader.length);
                        for (var indexTable = 0; indexTable < ttf.NumTables; indexTable++) {
                            if (ttf.Tables[indexTable].Required) {
                                if (ttf.Tables[indexTable].NewTable != null) {
                                    outputStream.writeBytes(ttf.Tables[indexTable].NewTable, 0, ttf.Tables[indexTable].NewLength);
                                }
                                else {
                                    outputStream.writeBytes(buff, ttf.Tables[indexTable].Offset, ttf.Tables[indexTable].NewLength);
                                }
                                var remainder = ttf.Tables[indexTable].NewLength % 4;
                                if (remainder > 0) {
                                    outputStream.write(Array.create(Number, 4 - remainder), 0, 4 - remainder);
                                }
                            }
                        }
                        outputStream.flush();
                        //#endregion
                    }
                    return outputStream;
                };
                //#endregion
                PdfFonts.prototype.scanFontFile = function (buff, fontName) {
                    var ttf = null;
                    var tag = this.GetUInt32(buff, 0);
                    if (tag == 0x00010000) // sfnt version 1.0, TTF font
                     {
                        ttf = this.getTtfInfo(buff, 0);
                    }
                    else {
                        var ttcVer = this.GetUInt32(buff, 4);
                        if ((tag == 0x74746366) && ((ttcVer == 0x00010000) || (ttcVer == 0x00020000))) // ttcf version 1.0 or 2.0
                         {
                            //#region TTC font
                            var numFontsTtc = this.GetUInt32(buff, 8);
                            for (var indexTtc = numFontsTtc - 1; indexTtc >= 0; indexTtc--) {
                                var offset = this.GetUInt32(buff, 12 + indexTtc * 4);
                                var tagTtc = this.GetUInt32(buff, offset);
                                if (tagTtc == 0x00010000) // sfnt version 1.0
                                 {
                                    ttf = this.getTtfInfo(buff, offset);
                                    if (ttf.FontName.contains(fontName)) {
                                        break;
                                    }
                                }
                            }
                            //#endregion
                        }
                    }
                    return ttf;
                };
                PdfFonts.prototype.getCmapTable = function (buff, ttf) {
                    var charToGlyph = null;
                    var offsetCmapTable = ttf.Tables[ttf.IndexCmapTable].Offset;
                    var numCmapTables = this.GetUInt16(buff, offsetCmapTable + 2);
                    for (var indexRecord = 0; indexRecord < numCmapTables; indexRecord++) {
                        var offsetRecord = offsetCmapTable + 4 + indexRecord * 8;
                        var platformID = this.GetUInt16(buff, offsetRecord);
                        var encodingID = this.GetUInt16(buff, offsetRecord + 2);
                        var offsetTable = offsetCmapTable + this.GetUInt32(buff, offsetRecord + 4);
                        if ((platformID == 3) && (encodingID == 1)) // Unicode BMP (UCS-2)
                         {
                            var formatNumber = this.GetUInt16(buff, offsetTable);
                            if (formatNumber == 4) {
                                //#region cmap table Format 4
                                charToGlyph = Array.create(Number, 65536);
                                for (var indexT1 = 0; indexT1 < 65536; indexT1++)
                                    charToGlyph[indexT1] = 0xFFFF;
                                var segCountX2 = this.GetUInt16(buff, offsetTable + 6);
                                // int offsetGlyphIdArray = offsetTable + 14 + segCountX2 * 4 + 2;
                                for (var indexSeg = 0; indexSeg < segCountX2; indexSeg += 2) {
                                    var offsetSeg = offsetTable + 14 + indexSeg;
                                    var endCode = this.GetUInt16(buff, offsetSeg);
                                    var startCode = this.GetUInt16(buff, offsetSeg + 2 + segCountX2);
                                    var idDelta = this.GetInt16(buff, offsetSeg + 2 + segCountX2 * 2);
                                    var idRangeOffset = this.GetUInt16(buff, offsetSeg + 2 + segCountX2 * 3);
                                    if (startCode != 0xFFFF) {
                                        for (var indexChar = startCode; indexChar <= endCode; indexChar++) {
                                            var glyphId = 0xFFFF;
                                            if (idRangeOffset == 0) {
                                                glyphId = (idDelta + indexChar) & 0xFFFF;
                                            }
                                            else {
                                                var glyphIndexAddress = idRangeOffset + 2 * (indexChar - startCode) + (offsetSeg + 2 + segCountX2 * 3);
                                                glyphId = this.GetUInt16(buff, glyphIndexAddress);
                                                if (glyphId != 0)
                                                    glyphId += idDelta;
                                            }
                                            charToGlyph[indexChar] = glyphId;
                                        }
                                    }
                                }
                                //#endregion
                                //// fill glyphs list
                                // for (let indexChar: number = 0; indexChar < this.MappedSymbolsCount; indexChar++) {
                                //    this.GlyphList[indexChar] = charToGlyph[this.UnicodeMapBack[indexChar]];
                                // }
                            }
                        }
                    }
                    return charToGlyph;
                };
                PdfFonts.prototype.copyUint8Array = function (source, from, destination, to, count) {
                    for (var index = 0; index < count; index++) {
                        destination[to + index] = source[from + index];
                    }
                };
                //#endregion
                //#region get TtfInfo
                PdfFonts.prototype.getTtfInfo = function (buff, bufOffset) {
                    var ttf = new TtfInfo();
                    ttf.HeaderOffset = bufOffset;
                    ttf.SfntVersion = this.GetUInt32(buff, ttf.HeaderOffset);
                    ttf.NumTables = this.GetUInt16(buff, ttf.HeaderOffset + 4);
                    ttf.NumTablesRequired = 0;
                    ttf.Tables = [];
                    for (var indexTable = 0; indexTable < ttf.NumTables; indexTable++)
                        ttf.Tables[indexTable] = new TableDirectoryItem();
                    for (var index = 0; index < ttf.NumTables; index++) {
                        var pos = ttf.HeaderOffset + this.TtfHeaderSize + index * 16;
                        var sbTable = new StringBuilder();
                        for (var tempIndex = 0; tempIndex < 4; tempIndex++) {
                            sbTable.append(String.fromCharCode(this.GetUInt8(buff, pos + tempIndex)));
                        }
                        ttf.Tables[index].Tag = this.GetUInt32(buff, pos);
                        ttf.Tables[index].TagString = sbTable.toString();
                        ttf.Tables[index].CheckSum = this.GetUInt32(buff, pos + 4);
                        ttf.Tables[index].Offset = this.GetUInt32(buff, pos + 8);
                        ttf.Tables[index].Length = this.GetUInt32(buff, pos + 12);
                        ttf.Tables[index].NewLength = ttf.Tables[index].Length;
                        for (var tempIndex = 0; tempIndex < this.TablesNames.length; tempIndex++) {
                            if (ttf.Tables[index].TagString == this.TablesNames[tempIndex]) {
                                ttf.Tables[index].Required = true;
                                ttf.NumTablesRequired++;
                                break;
                            }
                        }
                        switch (ttf.Tables[index].TagString) {
                            case "head":
                                // ttf.HeadCheckSumOffset = ttf.Tables[index].Offset + 8;
                                // this.SetUInt32(buff, ttf.HeadCheckSumOffset, 0);
                                ttf.IndexToLocFormat = this.GetUInt16(buff, ttf.Tables[index].Offset + 50);
                                break;
                            case "maxp":
                                ttf.NumGlyphs = this.GetUInt16(buff, ttf.Tables[index].Offset + 4);
                                break;
                            case "loca":
                                ttf.IndexLocaTable = index;
                                break;
                            case "glyf":
                                ttf.IndexGlyfTable = index;
                                break;
                            case "cmap":
                                ttf.IndexCmapTable = index;
                                break;
                            case "name":
                                //#region scan for font family name
                                var tableOffset = ttf.Tables[index].Offset;
                                var countNames = this.GetUInt16(buff, tableOffset + 2);
                                var storageOffset = this.GetUInt16(buff, tableOffset + 4);
                                for (var indexName = 0; indexName < countNames; indexName++) {
                                    var posName = tableOffset + 6 + indexName * 12;
                                    var platformID = this.GetUInt16(buff, posName);
                                    var encodingID = this.GetUInt16(buff, posName + 2);
                                    // let languageID: number = this.GetUInt16(buff, posName + 4);
                                    var nameID = this.GetUInt16(buff, posName + 6);
                                    var lengthName = this.GetUInt16(buff, posName + 8);
                                    var offsetName = this.GetUInt16(buff, posName + 10);
                                    if (((platformID == 3) && (encodingID == 1) && (nameID == 1)) ||
                                        ((platformID == 0) && (encodingID == 3) && (nameID == 1))) {
                                        var sbName = new StringBuilder();
                                        for (var indexChar = 0; indexChar < lengthName / 2; indexChar++) {
                                            sbName.append(String.fromCharCode(this.GetUInt16(buff, tableOffset + storageOffset + offsetName + indexChar * 2)));
                                        }
                                        var name_18 = sbName.toString();
                                        ttf.FontName.set(name_18, name_18);
                                    }
                                }
                                //#endregion
                                break;
                        }
                    }
                    return ttf;
                };
                //#endregion
                //#region getData & setData
                // private bufGetData: Uint8Array = new Uint8Array(4);
                PdfFonts.prototype.GetUInt8 = function (buff, pos) {
                    return buff[pos];
                };
                PdfFonts.prototype.GetUInt16 = function (buff, pos) {
                    return (buff[pos] << 8) + buff[pos + 1];
                };
                PdfFonts.prototype.GetUInt32 = function (buff, pos) {
                    return (buff[pos] << 24) + (buff[pos + 1] << 16) + (buff[pos + 2] << 8) + buff[pos + 3];
                };
                // private GetInt8(buff: Uint8Array, pos: number): number
                //      {
                //          let vvalue: number = buff[pos];
                //          return vvalue > 127 ? vvalue - 256 : vvalue;
                //      }
                PdfFonts.prototype.GetInt16 = function (buff, pos) {
                    var vvalue = (buff[pos] << 8) + buff[pos + 1];
                    return vvalue > 0x7fff ? vvalue - 0x10000 : vvalue;
                };
                // private GetInt32(buff: Uint8Array, pos: number): number
                // {
                //    this.bufGetData[0] = buff[pos + 3];
                //    this.bufGetData[1] = buff[pos + 2];
                //    this.bufGetData[2] = buff[pos + 1];
                //    this.bufGetData[3] = buff[pos + 0];
                //    let int32array = new Int32Array(
                //        this.bufGetData.buffer,
                //        this.bufGetData.byteOffset,
                //        1);
                //    return int32array[0];
                // }
                PdfFonts.prototype.SetUInt16 = function (buff, pos, value) {
                    buff[pos + 0] = (value >>> 8) & 0xFF;
                    buff[pos + 1] = value & 0xFF;
                };
                PdfFonts.prototype.SetUInt32 = function (buff, pos, value) {
                    buff[pos + 0] = (value >>> 24) & 0xFF;
                    buff[pos + 1] = (value >>> 16) & 0xFF;
                    buff[pos + 2] = (value >>> 8) & 0xFF;
                    buff[pos + 3] = value & 0xFF;
                };
                //#endregion
                //#endregion
                PdfFonts.prototype.clear = function () {
                    this.fonts = null;
                    this.fontList = null;
                    this.UnicodeMapsList = null;
                    this.GlyphMapsList = null;
                    this.Widths = null;
                    this.CharPdfNames = null;
                    this.UnicodeMap = null;
                    this.UnicodeMapBack = null;
                    this.GlyphList = null;
                    this.GlyphBackList = null;
                    this.GlyphRtfList = null;
                    this.SymsToPDF = null;
                    this.GlyphWidths = null;
                    this.fontsInfoStore.clear();
                };
                return PdfFonts;
            }(PdfFontInfo));
            Export.PdfFonts = PdfFonts;
            var FontsInfoStore = /** @class */ (function () {
                function FontsInfoStore() {
                }
               
                FontsInfoStore.prototype.clear = function () {
                    // Cache.Clear();
                };
                return FontsInfoStore;
            }());
            Export.FontsInfoStore = FontsInfoStore;
        })(Export = Report.Export || (Report.Export = {}));
    })(Report = Stimulsoft.Report || (Stimulsoft.Report = {}));
})(Stimulsoft || (Stimulsoft = {}));

var Stimulsoft;
(function (Stimulsoft) {
    var Report;
    (function (Report) {
        var Export;
        (function (Export) {
            var Color = Stimulsoft.System.Drawing.Color;
            var Graphics = Stimulsoft.System.Drawing.Graphics;
            var StiContext = Stimulsoft.Base.Context.StiContext;
            var StiContextPainter = Stimulsoft.Base.Context.StiContextPainter;
            var Point = Stimulsoft.System.Drawing.Point;
            var PointD = Stimulsoft.System.Drawing.Point;
            var Rectangle = Stimulsoft.System.Drawing.Rectangle;
            var RectangleD = Stimulsoft.System.Drawing.Rectangle;
            var StringFormat = Stimulsoft.System.Drawing.StringFormat;
            var StiRotationMode = Stimulsoft.Base.Drawing.StiRotationMode;
            var StiPushTranslateTransformGeom = Stimulsoft.Base.Context.StiPushTranslateTransformGeom;
            var StiPushRotateTransformGeom = Stimulsoft.Base.Context.StiPushRotateTransformGeom;
            var StiPopTransformGeom = Stimulsoft.Base.Context.StiPopTransformGeom;
            var StiBorderGeom = Stimulsoft.Base.Context.StiBorderGeom;
            var StiLineGeom = Stimulsoft.Base.Context.StiLineGeom;
            var StiLinesGeom = Stimulsoft.Base.Context.StiLinesGeom;
            var StiPushClipGeom = Stimulsoft.Base.Context.StiPushClipGeom;
            var StiPopClipGeom = Stimulsoft.Base.Context.StiPopClipGeom;
            var StiPushSmothingModeToAntiAliasGeom = Stimulsoft.Base.Context.StiPushSmothingModeToAntiAliasGeom;
            var StiPopSmothingModeGeom = Stimulsoft.Base.Context.StiPopSmothingModeGeom;
            var StiPushTextRenderingHintToAntiAliasGeom = Stimulsoft.Base.Context.StiPushTextRenderingHintToAntiAliasGeom;
            var StiPopTextRenderingHintGeom = Stimulsoft.Base.Context.StiPopTextRenderingHintGeom;
            var StiCurveGeom = Stimulsoft.Base.Context.StiCurveGeom;
            var StiEllipseGeom = Stimulsoft.Base.Context.StiEllipseGeom;
            var StiCachedShadowGeom = Stimulsoft.Base.Context.StiCachedShadowGeom;
            var StiShadowSides = Stimulsoft.Base.Drawing.StiShadowSides;
            var StiSolidBrush = Stimulsoft.Base.Drawing.StiSolidBrush;
            var StiShadowGeom = Stimulsoft.Base.Context.StiShadowGeom;
            var StiTextGeom = Stimulsoft.Base.Context.StiTextGeom;
            var StiPathGeom = Stimulsoft.Base.Context.StiPathGeom;
            var StiPieSegmentGeom = Stimulsoft.Base.Context.StiPieSegmentGeom;
            var StiArcSegmentGeom = Stimulsoft.Base.Context.StiArcSegmentGeom;
            var StiLineSegmentGeom = Stimulsoft.Base.Context.StiLineSegmentGeom;
            var StiLinesSegmentGeom = Stimulsoft.Base.Context.StiLinesSegmentGeom;
            var StiCurveSegmentGeom = Stimulsoft.Base.Context.StiCurveSegmentGeom;
            var StiCloseFigureSegmentGeom = Stimulsoft.Base.Context.StiCloseFigureSegmentGeom;
            var Matrix = Stimulsoft.System.Drawing.Drawing2D.Matrix;
            var IStiChart = Stimulsoft.Report.Chart.IStiChart;
            var StiPenStyle = Stimulsoft.Base.Drawing.StiPenStyle;
            var Font = Stimulsoft.System.Drawing.Font;
            var StiBrush = Stimulsoft.Base.Drawing.StiBrush;
            var StiImageRotation = Stimulsoft.Report.Components.StiImageRotation;
            var StiPdfRenderChart = /** @class */ (function () {
                function StiPdfRenderChart() {
                }
                StiPdfRenderChart.renderChart = function (pp, assemble, pageNumber) {
                    var chart = pp.Component.sti.as(IStiChart);
                    //#region Calculate rotation transform
                    var scale = 0.96;
                    var rectWidth = pp.service.report.unit.convertToHInches(pp.Component.width) * scale;
                    var rectHeight = pp.service.report.unit.convertToHInches(pp.Component.height) * scale;
                    var angle = 0;
                    var deltaX = 0;
                    var deltaY = 0;
                    var scaleX = 1;
                    var scaleY = 1;
                    switch (chart.rotation) {
                        case StiImageRotation.Rotate90CCW:
                            angle = -90;
                            deltaY = rectHeight;
                            break;
                        case StiImageRotation.Rotate90CW:
                            angle = 90;
                            deltaX = rectWidth;
                            break;
                        case StiImageRotation.Rotate180:
                            angle = -180;
                            deltaX = rectWidth;
                            deltaY = rectHeight;
                            break;
                        case StiImageRotation.FlipVertical:
                            scaleY = -1;
                            deltaY = rectHeight;
                            break;
                        case StiImageRotation.FlipHorizontal:
                            scaleX = -1;
                            deltaX = rectWidth;
                            break;
                    }
                    switch (chart.rotation) {
                        case StiImageRotation.Rotate90CCW:
                        case StiImageRotation.Rotate90CW:
                            var temp = rectWidth;
                            rectWidth = rectHeight;
                            rectHeight = temp;
                            break;
                    }
                    if (!assemble && (chart.rotation != StiImageRotation.None)) {
                        var matrix2 = new Matrix(1, 0, 0, 1, 0, 0);
                        matrix2.translate(deltaX, deltaY);
                        matrix2.scale(scaleX, scaleY);
                        matrix2.rotate(angle);
                        pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} cm", pp.service.convertToString(matrix2.elements[0]), pp.service.convertToString(matrix2.elements[1]), pp.service.convertToString(matrix2.elements[2]), pp.service.convertToString(matrix2.elements[3]), pp.service.convertToString(matrix2.elements[4]), pp.service.convertToString(matrix2.elements[5]));
                    }
                    //#endregion
                    // let g: Graphics = new Graphics();
                    var painter = new StiContextPainter();
                    var context = new StiContext(painter, true, false, false, 1);
                    var storeIsAnimation = chart.isAnimation;
                    chart.isAnimation = false;
                    var chartGeom = chart.core.render(context, new RectangleD(0, 0, rectWidth, rectHeight), true);
                    chartGeom.drawGeom(context);
                    chart.isAnimation = storeIsAnimation;
                    var matrix = new Matrix(1, 0, 0, 1, 0, 0);
                    var chartScale = (pp.service.hiToTwips / 0.96);
                    matrix.translate(pp.X, pp.Y + pp.Height);
                    matrix.scale(1, -1);
                    matrix.scale(chartScale, chartScale);
                    var pdfGeomWriter = new Export.StiPdfGeomWriter(pp.service.pageStream, pp.service, assemble);
                    pdfGeomWriter.pageNumber = pageNumber;
                    pdfGeomWriter.matrixCache.push(matrix);
                    for (var _i = 0, _a = context.geoms; _i < _a.length; _i++) {
                        var geom = _a[_i];
                        if (geom.sti.is(StiPushTranslateTransformGeom)) {
                            var pushTranslateGeom = geom.sti.as(StiPushTranslateTransformGeom);
                            pdfGeomWriter.saveState();
                            pdfGeomWriter.translateTransform(pushTranslateGeom.x, pushTranslateGeom.y);
                        }
                        if (geom.sti.is(StiPushRotateTransformGeom)) {
                            var pushRotateGeom = geom.sti.as(StiPushRotateTransformGeom);
                            pdfGeomWriter.saveState();
                            pdfGeomWriter.rotateTransform(pushRotateGeom.angle);
                        }
                        if (geom.sti.is(StiPopTransformGeom)) {
                            pdfGeomWriter.restoreState();
                        }
                        if (geom.sti.is(StiPushClipGeom)) {
                            var clipGeom = geom.sti.as(StiPushClipGeom);
                            pdfGeomWriter.saveState();
                            pdfGeomWriter.setClip(clipGeom.clipRectangle);
                        }
                        if (geom.sti.is(StiPopClipGeom)) {
                            pdfGeomWriter.restoreState();
                        }
                        if (geom.sti.is(StiPushSmothingModeToAntiAliasGeom)) {
                            pdfGeomWriter.saveState();
                        }
                        if (geom.sti.is(StiPopSmothingModeGeom)) {
                            pdfGeomWriter.restoreState();
                        }
                        if (geom.sti.is(StiPushTextRenderingHintToAntiAliasGeom)) {
                            pdfGeomWriter.saveState();
                        }
                        if (geom.sti.is(StiPopTextRenderingHintGeom)) {
                            pdfGeomWriter.restoreState();
                        }
                        if (geom.sti.is(StiBorderGeom)) {
                            var border = geom.sti.as(StiBorderGeom);
                            if (border.background != null) {
                                pdfGeomWriter.fillRectangle(this.rectToRectangle(border.rect), border.background);
                            }
                            if (this.checkPenGeom(border.borderPen)) {
                                pdfGeomWriter.drawRectangle(this.rectToRectangle(border.rect), border.borderPen);
                            }
                        }
                        if (geom.sti.is(StiLineGeom)) {
                            var line = geom.sti.as(StiLineGeom);
                            if (this.checkPenGeom(line.pen)) {
                                pdfGeomWriter.drawLine(new Point(line.x1, line.y1), new Point(line.x2, line.y2), line.pen);
                            }
                        }
                        if (geom.sti.is(StiLinesGeom)) {
                            var lines = geom.sti.as(StiLinesGeom);
                            if (this.checkPenGeom(lines.pen)) {
                                pdfGeomWriter.drawPolyline(lines.points, lines.pen);
                            }
                        }
                        if (geom.sti.is(StiCurveGeom)) {
                            var curve = geom.sti.as(StiCurveGeom);
                            if (this.checkPenGeom(curve.pen)) {
                                pdfGeomWriter.drawSpline(curve.points, curve.tension, curve.pen);
                            }
                        }
                        if (geom.sti.is(StiEllipseGeom)) {
                            var ellipse = geom.sti.as(StiEllipseGeom);
                            if (ellipse.background != null) {
                                pdfGeomWriter.fillEllipse(this.rectToRectangle(ellipse.rect), ellipse.background);
                            }
                            if (this.checkPenGeom(ellipse.borderPen)) {
                                pdfGeomWriter.drawEllipse(this.rectToRectangle(ellipse.rect), ellipse.borderPen);
                            }
                        }
                        if (geom.sti.is(StiCachedShadowGeom)) {
                            var shadow = geom.sti.as(StiCachedShadowGeom);
                            var rect = shadow.rect;
                            var sides = shadow.sides;
                            var yTop = rect.y + 8;
                            var xLeft = rect.x + 8;
                            var edgeOffset = ((sides & StiShadowSides.Edge) > 0) ? 4 : 0;
                            if ((sides & StiShadowSides.Top) > 0) {
                                yTop = rect.y + 4;
                            }
                            if ((sides & StiShadowSides.Left) > 0) {
                                xLeft = rect.x + 4;
                            }
                            for (var index = 0; index < 3; index++) {
                                var pts = new Array();
                                if ((sides & StiShadowSides.Right) > 0) {
                                    pts.add(new Point(rect.right, yTop));
                                    if ((sides & StiShadowSides.Bottom) > 0) {
                                        pts.add(new Point(rect.right, rect.bottom));
                                        pts.add(new Point(xLeft, rect.bottom));
                                        pts.add(new Point(xLeft, rect.bottom + index + 1));
                                        pts.add(new Point(rect.right + index + 1, rect.bottom + index + 1));
                                    }
                                    else {
                                        pts.add(new Point(rect.right, rect.bottom + edgeOffset));
                                        pts.add(new Point(rect.right + index + 1, rect.bottom + edgeOffset));
                                    }
                                    pts.add(new Point(rect.right + index + 1, yTop));
                                }
                                else {
                                    pts.add(new Point(xLeft, rect.bottom));
                                    pts.add(new Point(rect.right + edgeOffset, rect.bottom));
                                    pts.add(new Point(rect.right + edgeOffset, rect.bottom + index + 1));
                                    pts.add(new Point(xLeft, rect.bottom + index + 1));
                                }
                                var shadowBrush = new StiSolidBrush(Color.fromArgb(40 - 10 * index, Color.black));
                                pdfGeomWriter.fillPolygon(pts, shadowBrush);
                            }
                        }
                        if (geom.sti.is(StiShadowGeom)) {
                            var shadow2 = geom.sti.as(StiShadowGeom);
                            // todo
                        }
                        if (geom.sti.is(StiTextGeom)) {
                            var text = geom.sti.as(StiTextGeom);
                            var font = new Font(text.font.fontName, text.font.fontSize, text.font.fontStyle, text.font.unit);
                            var sf = new StringFormat();
                            sf.alignment = text.stringFormat.alignment;
                            sf.formatFlags = text.stringFormat.formatFlags;
                            sf.hotkeyPrefix = text.stringFormat.hotkeyPrefix;
                            sf.lineAlignment = text.stringFormat.lineAlignment;
                            sf.trimming = text.stringFormat.trimming;
                            var brush = this.brushToStiBrush(text.brush);
                            if (text.isRotatedText) {
                                var point = new Point();
                                if (text.location.sti.is(Point)) {
                                    point = text.location.sti.as(Point);
                                }
                                else if (text.location.sti.is(PointD)) {
                                    var pointD = text.location.sti.as(PointD);
                                    point = new Point(pointD.x, pointD.y);
                                }
                                else {
                                    var rect2 = this.rectToRectangle(text.location);
                                    point = new Point(rect2.x + rect2.width / 2, rect2.y + rect2.height / 2);
                                }
                                var textSize = Graphics.measureString(text.text, font, text.maximalWidth);
                                var textRect = new Rectangle(0, 0, textSize.width + 2.5, textSize.height);
                                var startPoint = this.getStartPoint(text.rotationMode, textRect);
                                textRect.x -= startPoint.x;
                                textRect.y -= startPoint.y;
                                pdfGeomWriter.saveState();
                                pdfGeomWriter.translateTransform(point.x, point.y);
                                pdfGeomWriter.rotateTransform(text.angle);
                                pdfGeomWriter.drawString(text.text, font, brush, textRect, sf);
                                pdfGeomWriter.restoreState();
                            }
                            else {
                                pdfGeomWriter.drawString(text.text, font, brush, this.rectToRectangle(text.location), sf);
                            }
                        }
                        if (geom.sti.is(StiPathGeom)) {
                            var path = geom.sti.as(StiPathGeom);
                            pdfGeomWriter.beginPath();
                            for (var _b = 0, _c = path.geoms; _b < _c.length; _b++) {
                                var geom2 = _c[_b];
                                if (geom2.sti.is(StiPieSegmentGeom)) {
                                    var pie = geom2.sti.as(StiPieSegmentGeom);
                                    pdfGeomWriter.drawPie(pie.rect, pie.startAngle, pie.sweepAngle);
                                }
                                if (geom2.sti.is(StiArcSegmentGeom)) {
                                    var arc = geom2.sti.as(StiArcSegmentGeom);
                                    pdfGeomWriter.drawArc(arc.rect, arc.startAngle, arc.sweepAngle);
                                }
                                if (geom2.sti.is(StiLineSegmentGeom)) {
                                    var linep = geom2.sti.as(StiLineSegmentGeom);
                                    pdfGeomWriter.drawLine(new Point(linep.x1, linep.y1), new Point(linep.x2, linep.y2), null);
                                }
                                if (geom2.sti.is(StiLinesSegmentGeom)) {
                                    var linesp = geom2.sti.as(StiLinesSegmentGeom);
                                    pdfGeomWriter.drawPolyline(linesp.points, null);
                                }
                                if (geom2.sti.is(StiCurveSegmentGeom)) {
                                    var curvep = geom2.sti.as(StiCurveSegmentGeom);
                                    pdfGeomWriter.drawSpline(curvep.points, curvep.tension, null);
                                }
                                if (geom2.sti.is(StiCloseFigureSegmentGeom)) {
                                    pdfGeomWriter.closeFigure();
                                }
                            }
                            pdfGeomWriter.closeFigure();
                            pdfGeomWriter.endPath();
                            if (path.background != null) {
                                pdfGeomWriter.fillPath(path.background);
                            }
                            if (this.checkPenGeom(path.pen)) {
                                pdfGeomWriter.strokePath(path.pen);
                            }
                        }
                    }
                };
                StiPdfRenderChart.getStartPoint = function (rotationMode, textRect) {
                    var centerPoint = new Point(textRect.x + (textRect.width / 2), textRect.y + (textRect.height / 2));
                    switch (rotationMode) {
                        case StiRotationMode.LeftCenter:
                            return new Point(textRect.x, centerPoint.y);
                        case StiRotationMode.LeftBottom:
                            return new Point(textRect.x, textRect.bottom);
                        case StiRotationMode.CenterTop:
                            return new Point(centerPoint.x, textRect.top);
                        case StiRotationMode.CenterCenter:
                            return centerPoint;
                        case StiRotationMode.CenterBottom:
                            return new Point(centerPoint.x, textRect.bottom);
                        case StiRotationMode.RightTop:
                            return new Point(textRect.right, textRect.top);
                        case StiRotationMode.RightCenter:
                            return new Point(textRect.right, centerPoint.y);
                        case StiRotationMode.RightBottom:
                            return new Point(textRect.right, textRect.bottom);
                        default:
                            return new Point(textRect.x, textRect.y);
                    }
                };
                StiPdfRenderChart.rectToRectangle = function (rect) {
                    if (rect == null)
                        return new Rectangle();
                    if (rect.sti.is(Rectangle))
                        return rect.sti.as(Rectangle);
                    if (rect.sti.is(RectangleD)) {
                        var rectangle = rect.sti.as(RectangleD);
                        return new Rectangle(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
                    }
                    return new Rectangle();
                };
                StiPdfRenderChart.brushToStiBrush = function (brush) {
                    if (brush == null)
                        return null;
                    if (brush.sti.is(Color)) {
                        return new StiSolidBrush(brush.sti.as(Color));
                    }
                    if (brush.sti.is(StiBrush)) {
                        return brush.sti.as(StiBrush);
                    }
                    return null;
                };
                StiPdfRenderChart.checkPenGeom = function (penGeom) {
                    return !((penGeom == null) || (penGeom.brush == null) || (penGeom.penStyle == StiPenStyle.None));
                };
                return StiPdfRenderChart;
            }());
            Export.StiPdfRenderChart = StiPdfRenderChart;
        })(Export = Report.Export || (Report.Export = {}));
    })(Report = Stimulsoft.Report || (Stimulsoft.Report = {}));
})(Stimulsoft || (Stimulsoft = {}));
var Stimulsoft;
(function (Stimulsoft) {
    var Report;
    (function (Report) {
        var Export;
        (function (Export) {
            var Color = Stimulsoft.System.Drawing.Color;
            var StiBrush = Stimulsoft.Base.Drawing.StiBrush;
            var StiGradientBrush = Stimulsoft.Base.Drawing.StiGradientBrush;
            var StiGlareBrush = Stimulsoft.Base.Drawing.StiGlareBrush;
            var StiHatchBrush = Stimulsoft.Base.Drawing.StiHatchBrush;
            var StiGlassBrush = Stimulsoft.Base.Drawing.StiGlassBrush;
            var IStiBrush = Stimulsoft.Report.Components.IStiBrush;
            var StiBorderSides = Stimulsoft.Base.Drawing.StiBorderSides;
            var IStiBorder = Stimulsoft.Report.Components.IStiBorder;
            var StiBorderSide = Stimulsoft.Base.Drawing.StiBorderSide;
            var StiAdvancedBorder = Stimulsoft.Base.Drawing.StiAdvancedBorder;
            var StiPenStyle = Stimulsoft.Base.Drawing.StiPenStyle;
            var StiShape = Stimulsoft.Report.Components.StiShape;
            var StiVerticalLineShapeType = Stimulsoft.Report.Components.StiVerticalLineShapeType;
            var StiHorizontalLineShapeType = Stimulsoft.Report.Components.StiHorizontalLineShapeType;
            var StiTopAndBottomLineShapeType = Stimulsoft.Report.Components.StiTopAndBottomLineShapeType;
            var StiLeftAndRightLineShapeType = Stimulsoft.Report.Components.StiLeftAndRightLineShapeType;
            var StiRectangleShapeType = Stimulsoft.Report.Components.StiRectangleShapeType;
            var StiRoundedRectangleShapeType = Stimulsoft.Report.Components.StiRoundedRectangleShapeType;
            var StiDiagonalDownLineShapeType = Stimulsoft.Report.Components.StiDiagonalDownLineShapeType;
            var StiDiagonalUpLineShapeType = Stimulsoft.Report.Components.StiDiagonalUpLineShapeType;
            var StiTriangleShapeType = Stimulsoft.Report.Components.StiTriangleShapeType;
            var StiOvalShapeType = Stimulsoft.Report.Components.StiOvalShapeType;
            var StiArrowShapeType = Stimulsoft.Report.Components.StiArrowShapeType;
            var StiOctagonShapeType = Stimulsoft.Report.Components.StiOctagonShapeType;
            var StiComplexArrowShapeType = Stimulsoft.Report.Components.StiComplexArrowShapeType;
            var StiBentArrowShapeType = Stimulsoft.Report.Components.StiBentArrowShapeType;
            var StiChevronShapeType = Stimulsoft.Report.Components.StiChevronShapeType;
            var StiDivisionShapeType = Stimulsoft.Report.Components.StiDivisionShapeType;
            var StiEqualShapeType = Stimulsoft.Report.Components.StiEqualShapeType;
            var StiFlowchartCardShapeType = Stimulsoft.Report.Components.StiFlowchartCardShapeType;
            var StiFlowchartCollateShapeType = Stimulsoft.Report.Components.StiFlowchartCollateShapeType;
            var StiFlowchartDecisionShapeType = Stimulsoft.Report.Components.StiFlowchartDecisionShapeType;
            var StiFlowchartManualInputShapeType = Stimulsoft.Report.Components.StiFlowchartManualInputShapeType;
            var StiFlowchartOffPageConnectorShapeType = Stimulsoft.Report.Components.StiFlowchartOffPageConnectorShapeType;
            var StiFlowchartPreparationShapeType = Stimulsoft.Report.Components.StiFlowchartPreparationShapeType;
            var StiFlowchartSortShapeType = Stimulsoft.Report.Components.StiFlowchartSortShapeType;
            var StiFrameShapeType = Stimulsoft.Report.Components.StiFrameShapeType;
            var StiMinusShapeType = Stimulsoft.Report.Components.StiMinusShapeType;
            var StiMultiplyShapeType = Stimulsoft.Report.Components.StiMultiplyShapeType;
            var StiParallelogramShapeType = Stimulsoft.Report.Components.StiParallelogramShapeType;
            var StiPlusShapeType = Stimulsoft.Report.Components.StiPlusShapeType;
            var StiRegularPentagonShapeType = Stimulsoft.Report.Components.StiRegularPentagonShapeType;
            var StiTrapezoidShapeType = Stimulsoft.Report.Components.StiTrapezoidShapeType;
            var StiSnipSameSideCornerRectangleShapeType = Stimulsoft.Report.Components.StiSnipSameSideCornerRectangleShapeType;
            var StiSnipDiagonalSideCornerRectangleShapeType = Stimulsoft.Report.Components.StiSnipDiagonalSideCornerRectangleShapeType;
            var StiShapeDirection = Stimulsoft.Report.Components.StiShapeDirection;
            var Rectangle = Stimulsoft.System.Drawing.Rectangle;
            var StiCheckBox = Stimulsoft.Report.Components.StiCheckBox;
            var StiCheckStyle = Stimulsoft.Report.Components.StiCheckStyle;
            var StiRoundedRectanglePrimitive = Stimulsoft.Report.Components.StiRoundedRectanglePrimitive;
            var StiString = Stimulsoft.System.StiString;
            var StiPdfRenderPrimitives = /** @class */ (function () {
                function StiPdfRenderPrimitives() {
                }
                StiPdfRenderPrimitives.renderBorder1 = function (pp) {
                    // fill band
                    var tempColor = Color.transparent;
                    var mBrush = pp.Component.sti.as(IStiBrush);
                    if ((mBrush != null) && (mBrush.brush != null)) {
                        tempColor = StiBrush.toColor(mBrush.brush);
                    }
                    // StiRichText mRich = pp.Component as StiRichText;
                    // if (mRich != null) {
                    //    tempColor = mRich.BackColor;
                    // }
                    // fill color
                    pp.service.setNonStrokeColor(tempColor);
                    if (mBrush != null && mBrush.brush != null) {
                        pp.service.storeShadingData2(pp.X, pp.Y, pp.Width, pp.Height, mBrush.brush);
                        if (mBrush.brush.sti.is(StiGradientBrush) || mBrush.brush.sti.is(StiGlareBrush)) {
                            pp.service.pageStream.writeLine("/Pattern cs /P{0} scn", 1 + pp.service.shadingCurrent);
                        }
                        if (mBrush.brush.sti.is(StiHatchBrush)) {
                            var hBrush = mBrush.brush.sti.as(StiHatchBrush);
                            pp.service.pageStream.writeLine("/Cs1 cs /PH{0} scn", pp.service.getHatchNumber(hBrush) + 1);
                        }
                        if (mBrush.brush.sti.is(StiGlassBrush)) {
                            var glass = mBrush.brush.sti.as(StiGlassBrush);
                            // if (glass.drawHatch) {
                            //    pp.service.pageStream.writeLine("/Cs1 cs /PH{0} scn", GetHatchNumber(glass.GetTopBrush() as HatchBrush) + 1);
                            // }
                            // else {
                            //    pp.service.setNonStrokeColor(glass.GetTopColor());
                            // }
                            // pp.service.pageStream.writeLine("{0} {1} {2} {3} re f",
                            //    pp.service.convertToString(pp.X),
                            //    pp.service.convertToString(pp.Y + pp.Height / 2),
                            //    pp.service.convertToString(pp.Width),
                            //    pp.service.convertToString(pp.Height / 2));
                            // if (glass.drawHatch) {
                            //    pp.service.pageStream.writeLine("/Cs1 cs /PH{0} scn", GetHatchNumber(glass.GetBottomBrush() as HatchBrush) + 1);
                            // }
                            // else {
                            //    pp.service.setNonStrokeColor(glass.GetBottomColor());
                            // }
                            // pp.service.pageStream.writeLine("{0} {1} {2} {3} re f",
                            //    pp.service.convertToString(pp.X),
                            //    pp.service.convertToString(pp.Y),
                            //    pp.service.convertToString(pp.Width),
                            //    pp.service.convertToString(pp.Height / 2));
                            // tempColor = Color.transparent;
                        }
                    }
                    if (tempColor.a != 0) {
                        pp.service.pageStream.writeLine("{0} {1} {2} {3} re f", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.Width), pp.service.convertToString(pp.Height));
                    }
                };
                StiPdfRenderPrimitives.renderBorder2 = function (pp) {
                    // draw border
                    var mBorder = pp.Component.sti.as(IStiBorder);
                    if (mBorder != null) {
                        var tempColor = Color.transparent;
                        // draw shadow
                        if ((mBorder.border.dropShadow) && (mBorder.border.shadowBrush != null)) {
                            tempColor = StiBrush.toColor(mBorder.border.shadowBrush);
                            if (tempColor.a != 0) {
                                var shadowSize = mBorder.border.shadowSize * 0.8;
                                // fill color
                                pp.service.setNonStrokeColor(tempColor);
                                pp.service.pageStream.writeLine("{0} {1} {2} {3} re f", pp.service.convertToString(pp.X + shadowSize), pp.service.convertToString(pp.Y - shadowSize), pp.service.convertToString(pp.Width - shadowSize), pp.service.convertToString(shadowSize));
                                pp.service.pageStream.writeLine("{0} {1} {2} {3} re f", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y - shadowSize), pp.service.convertToString(shadowSize), pp.service.convertToString(pp.Height));
                            }
                        }
                        var border = new StiBorderSide(mBorder.border.color, mBorder.border.size, mBorder.border.style);
                        var advBorder = mBorder.border.sti.as(StiAdvancedBorder);
                        var useAdvBorder = advBorder != null;
                        var needBorderLeft = mBorder.border.isLeftBorderSidePresent;
                        var needBorderRight = mBorder.border.isRightBorderSidePresent;
                        var needBorderTop = mBorder.border.isTopBorderSidePresent;
                        var needBorderBottom = mBorder.border.isBottomBorderSidePresent;
                        var needPush = (mBorder.border.style != StiPenStyle.None) && (mBorder.border.style != StiPenStyle.Solid);
                        var needDraw = (mBorder.border.side != StiBorderSides.None) && (mBorder.border.style != StiPenStyle.None);
                        if (useAdvBorder) {
                            needDraw = advBorder.side != StiBorderSides.None;
                        }
                        if (needDraw) {
                            var offset = 0;
                            if (!useAdvBorder) {
                                if (needPush) {
                                    pp.service.pageStream.writeLine("q");
                                    pp.service.pushColorToStack();
                                }
                                offset = this.storeBorderSideData(border, pp);
                            }
                            if ((!useAdvBorder) && (mBorder.border.side == StiBorderSides.All)) {
                                // stroke border
                                pp.service.pageStream.writeLine("{0} {1} {2} {3} re S", pp.service.convertToString(pp.X - offset), pp.service.convertToString(pp.Y - offset), pp.service.convertToString(pp.Width + offset * 2), pp.service.convertToString(pp.Height + offset * 2));
                                if (mBorder.border.style == StiPenStyle.Double) {
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} re S", pp.service.convertToString(pp.X + offset), pp.service.convertToString(pp.Y + offset), pp.service.convertToString(pp.Width - offset * 2), pp.service.convertToString(pp.Height - offset * 2));
                                }
                            }
                            else {
                                // paint border by line
                                if (needBorderLeft) {
                                    if (useAdvBorder) {
                                        border = advBorder.leftSide;
                                        if (border.style != StiPenStyle.Solid) {
                                            pp.service.pageStream.writeLine("q");
                                            pp.service.pushColorToStack();
                                        }
                                        offset = this.storeBorderSideData(border, pp);
                                    }
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X - offset), pp.service.convertToString(pp.Y - offset));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X - offset), pp.service.convertToString(pp.Y + pp.Height + offset));
                                    if (border.style == StiPenStyle.Double) {
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X + offset), pp.service.convertToString(pp.Y + (needBorderBottom ? offset : -offset)));
                                        pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + offset), pp.service.convertToString(pp.Y + pp.Height + (needBorderTop ? -offset : offset)));
                                    }
                                    if (useAdvBorder && (border.style != StiPenStyle.Solid)) {
                                        pp.service.pageStream.writeLine("Q");
                                        pp.service.popColorFromStack();
                                    }
                                }
                                if (needBorderRight) {
                                    if (useAdvBorder) {
                                        border = advBorder.rightSide;
                                        if (border.style != StiPenStyle.Solid) {
                                            pp.service.pageStream.writeLine("q");
                                            pp.service.pushColorToStack();
                                        }
                                        offset = this.storeBorderSideData(border, pp);
                                    }
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X + pp.Width + offset), pp.service.convertToString(pp.Y - offset));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + pp.Width + offset), pp.service.convertToString(pp.Y + pp.Height + offset));
                                    if (border.style == StiPenStyle.Double) {
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X + pp.Width - offset), pp.service.convertToString(pp.Y + (needBorderBottom ? offset : -offset)));
                                        pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + pp.Width - offset), pp.service.convertToString(pp.Y + pp.Height + (needBorderTop ? -offset : offset)));
                                    }
                                    if (useAdvBorder && (border.style != StiPenStyle.Solid)) {
                                        pp.service.pageStream.writeLine("Q");
                                        pp.service.popColorFromStack();
                                    }
                                }
                                if (needBorderTop) {
                                    if (useAdvBorder) {
                                        border = advBorder.topSide;
                                        if (border.style != StiPenStyle.Solid) {
                                            pp.service.pageStream.writeLine("q");
                                            pp.service.pushColorToStack();
                                        }
                                        offset = this.storeBorderSideData(border, pp);
                                    }
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X - offset), pp.service.convertToString(pp.Y + pp.Height + offset));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + pp.Width + offset), pp.service.convertToString(pp.Y + pp.Height + offset));
                                    if (border.style == StiPenStyle.Double) {
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X + (needBorderLeft ? offset : -offset)), pp.service.convertToString(pp.Y + pp.Height - offset));
                                        pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + pp.Width + (needBorderRight ? -offset : offset)), pp.service.convertToString(pp.Y + pp.Height - offset));
                                    }
                                    if (useAdvBorder && (border.style != StiPenStyle.Solid)) {
                                        pp.service.pageStream.writeLine("Q");
                                        pp.service.popColorFromStack();
                                    }
                                }
                                if (needBorderBottom) {
                                    if (useAdvBorder) {
                                        border = advBorder.bottomSide;
                                        if (border.style != StiPenStyle.Solid) {
                                            pp.service.pageStream.writeLine("q");
                                            pp.service.pushColorToStack();
                                        }
                                        offset = this.storeBorderSideData(border, pp);
                                    }
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X - offset), pp.service.convertToString(pp.Y - offset));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + pp.Width + offset), pp.service.convertToString(pp.Y - offset));
                                    if (border.style == StiPenStyle.Double) {
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X + (needBorderLeft ? offset : -offset)), pp.service.convertToString(pp.Y + offset));
                                        pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + pp.Width + (needBorderRight ? -offset : offset)), pp.service.convertToString(pp.Y + offset));
                                    }
                                    if (useAdvBorder && (border.style != StiPenStyle.Solid)) {
                                        pp.service.pageStream.writeLine("Q");
                                        pp.service.popColorFromStack();
                                    }
                                }
                            }
                            if (!useAdvBorder && needPush) {
                                pp.service.pageStream.writeLine("Q");
                                pp.service.popColorFromStack();
                            }
                        }
                    }
                };
                StiPdfRenderPrimitives.storeBorderSideData = function (border, pp) {
                    // set border size
                    var borderSizeHi = border.size;
                    if (borderSizeHi < 1)
                        borderSizeHi = 1;
                    if (border.style == StiPenStyle.Double)
                        borderSizeHi = 1;
                    var borderSize = borderSizeHi * pp.service.hiToTwips * 0.9;
                    pp.service.pageStream.writeLine("{0} w", pp.service.convertToString(borderSize));
                    // set border style
                    var dash = this.getPenStyleDashString(border.style, borderSize * 0.04, pp);
                    if (dash != null) {
                        pp.service.pageStream.writeLine(dash);
                    }
                    // stroke color
                    pp.service.setStrokeColor(border.color);
                    return (border.style == StiPenStyle.Double ? borderSize : 0);
                };
                StiPdfRenderPrimitives.getPenStyleDashString = function (style, step, pp) {
                    switch (style) {
                        case StiPenStyle.Dot:
                            return StiString.format("[{0} {1}] 0 d", pp.service.convertToString(step), pp.service.convertToString(step * 58));
                        case StiPenStyle.Dash:
                            return StiString.format("[{0} {1}] 0 d", pp.service.convertToString(step * 49.5), pp.service.convertToString(step * 62));
                        case StiPenStyle.DashDot:
                            return StiString.format("[{0} {1} {2} {1}] 0 d", pp.service.convertToString(step * 50), pp.service.convertToString(step * 55), pp.service.convertToString(step));
                        case StiPenStyle.DashDotDot:
                            return StiString.format("[{0} {1} {2} {1} {2} {1}] 0 d", pp.service.convertToString(step * 50), pp.service.convertToString(step * 55), pp.service.convertToString(step));
                    }
                    return null;
                };
                StiPdfRenderPrimitives.checkShape = function (shape) {
                    if (shape.shapeType.sti.is(StiVerticalLineShapeType) ||
                        shape.shapeType.sti.is(StiHorizontalLineShapeType) ||
                        shape.shapeType.sti.is(StiTopAndBottomLineShapeType) ||
                        shape.shapeType.sti.is(StiLeftAndRightLineShapeType) ||
                        shape.shapeType.sti.is(StiRectangleShapeType) ||
                        shape.shapeType.sti.is(StiRoundedRectangleShapeType) ||
                        shape.shapeType.sti.is(StiDiagonalDownLineShapeType) ||
                        shape.shapeType.sti.is(StiDiagonalUpLineShapeType) ||
                        shape.shapeType.sti.is(StiTriangleShapeType) ||
                        shape.shapeType.sti.is(StiOvalShapeType) ||
                        shape.shapeType.sti.is(StiArrowShapeType) ||
                        shape.shapeType.sti.is(StiOctagonShapeType) ||
                        shape.shapeType.sti.is(StiComplexArrowShapeType) ||
                        shape.shapeType.sti.is(StiBentArrowShapeType) ||
                        shape.shapeType.sti.is(StiChevronShapeType) ||
                        shape.shapeType.sti.is(StiDivisionShapeType) ||
                        shape.shapeType.sti.is(StiEqualShapeType) ||
                        shape.shapeType.sti.is(StiFlowchartCardShapeType) ||
                        shape.shapeType.sti.is(StiFlowchartCollateShapeType) ||
                        shape.shapeType.sti.is(StiFlowchartDecisionShapeType) ||
                        shape.shapeType.sti.is(StiFlowchartManualInputShapeType) ||
                        shape.shapeType.sti.is(StiFlowchartOffPageConnectorShapeType) ||
                        shape.shapeType.sti.is(StiFlowchartPreparationShapeType) ||
                        shape.shapeType.sti.is(StiFlowchartSortShapeType) ||
                        shape.shapeType.sti.is(StiFrameShapeType) ||
                        shape.shapeType.sti.is(StiMinusShapeType) ||
                        shape.shapeType.sti.is(StiMultiplyShapeType) ||
                        shape.shapeType.sti.is(StiParallelogramShapeType) ||
                        shape.shapeType.sti.is(StiPlusShapeType) ||
                        shape.shapeType.sti.is(StiRegularPentagonShapeType) ||
                        shape.shapeType.sti.is(StiTrapezoidShapeType) ||
                        shape.shapeType.sti.is(StiSnipSameSideCornerRectangleShapeType) ||
                        shape.shapeType.sti.is(StiSnipDiagonalSideCornerRectangleShapeType)) {
                        return true;
                    }
                    return false;
                };
                StiPdfRenderPrimitives.renderShape = function (pp, imageResolution) {
                    var shape = pp.Component.sti.as(StiShape);
                    if (shape != null) {
                        if (this.checkShape(shape) == true) {
                            var mBrush = pp.Component.sti.as(IStiBrush);
                            var geomWriter = new Export.StiPdfGeomWriter(pp.service.pageStream, pp.service, false);
                            // fill color
                            var tempColor = Color.transparent;
                            if (mBrush != null)
                                tempColor = StiBrush.toColor(mBrush.brush);
                            if (tempColor.a != 0) {
                                pp.service.setNonStrokeColor(tempColor);
                            }
                            if (mBrush != null) {
                                if (mBrush.brush.sti.is(StiGradientBrush) || mBrush.brush.sti.is(StiGlareBrush)) {
                                    pp.service.storeShadingData2(pp.X, pp.Y, pp.Width, pp.Height, mBrush.brush);
                                    pp.service.pageStream.writeLine("/Pattern cs /P{0} scn", 1 + pp.service.shadingCurrent);
                                }
                                if (mBrush.brush.sti.is(StiHatchBrush)) {
                                    var hBrush = mBrush.brush.sti.as(StiHatchBrush);
                                    pp.service.pageStream.writeLine("/Cs1 cs /PH{0} scn", pp.service.getHatchNumber(hBrush) + 1);
                                }
                            }
                            // stroke color
                            var tempColor2 = shape.borderColor;
                            pp.service.setStrokeColor(tempColor2);
                            var needFill = tempColor.a > 0;
                            var needStroke = shape.style != StiPenStyle.None;
                            if (!needFill && !needStroke)
                                return;
                            var st = needFill ? (needStroke ? "B" : "f") : (needStroke ? "S" : "n");
                            pp.service.pageStream.writeLine("{0} w", pp.service.convertToString(shape.size * pp.service.hiToTwips));
                            pp.service.pageStream.writeLine("q");
                            // set line style
                            var step = shape.size * pp.service.hiToTwips * 0.04;
                            switch (shape.style) {
                                case StiPenStyle.Dot:
                                    pp.service.pageStream.writeLine("[{0} {1}] 0 d", pp.service.convertToString(step), pp.service.convertToString(step * 55));
                                    break;
                                case StiPenStyle.Dash:
                                    pp.service.pageStream.writeLine("[{0} {1}] 0 d", pp.service.convertToString(step * 50), pp.service.convertToString(step * 55));
                                    break;
                                case StiPenStyle.DashDot:
                                    pp.service.pageStream.writeLine("[{0} {1} {2} {1}] 0 d", pp.service.convertToString(step * 50), pp.service.convertToString(step * 55), pp.service.convertToString(step));
                                    break;
                                case StiPenStyle.DashDotDot:
                                    pp.service.pageStream.writeLine("[{0} {1} {2} {1} {2} {1}] 0 d", pp.service.convertToString(step * 50), pp.service.convertToString(step * 55), pp.service.convertToString(step));
                                    break;
                            }
                            if (shape.shapeType.sti.is(StiVerticalLineShapeType)) {
                                if (needFill) {
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} re f", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.Width), pp.service.convertToString(pp.Height));
                                }
                                if (needStroke) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y + pp.Height));
                                }
                            }
                            if (shape.shapeType.sti.is(StiHorizontalLineShapeType)) {
                                if (needFill) {
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} re f", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.Width), pp.service.convertToString(pp.Height));
                                }
                                if (needStroke) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height / 2));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height / 2));
                                }
                            }
                            if (shape.shapeType.sti.is(StiTopAndBottomLineShapeType)) {
                                if (needFill) {
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} re f", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.Width), pp.service.convertToString(pp.Height));
                                }
                                if (needStroke) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y));
                                }
                            }
                            if (shape.shapeType.sti.is(StiLeftAndRightLineShapeType)) {
                                if (needFill) {
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} re f", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.Width), pp.service.convertToString(pp.Height));
                                }
                                if (needStroke) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height));
                                }
                            }
                            if (shape.shapeType.sti.is(StiRectangleShapeType)) {
                                pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y));
                                pp.service.pageStream.writeLine("{0} {1} l " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                            }
                            if (shape.shapeType.sti.is(StiDiagonalDownLineShapeType)) {
                                if (needFill) {
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} re f", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.Width), pp.service.convertToString(pp.Height));
                                }
                                if (needStroke) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y));
                                }
                            }
                            if (shape.shapeType.sti.is(StiDiagonalUpLineShapeType)) {
                                if (needFill) {
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} re f", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.Width), pp.service.convertToString(pp.Height));
                                }
                                if (needStroke) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height));
                                }
                            }
                            if (shape.shapeType.sti.is(StiTriangleShapeType)) {
                                var ssd = (shape.shapeType.sti.as(StiTriangleShapeType)).direction;
                                if (ssd == StiShapeDirection.Up) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                }
                                if (ssd == StiShapeDirection.Down) {
                                    if (needFill)
                                        st = needStroke ? "B*" : "f*";
                                    else
                                        st = needStroke ? "S" : "n";
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} l " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height));
                                }
                                if (ssd == StiShapeDirection.Left) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height / 2));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} l " + st, pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y));
                                }
                                if (ssd == StiShapeDirection.Right) {
                                    if (needFill)
                                        st = needStroke ? "B*" : "f*";
                                    else
                                        st = needStroke ? "S" : "n";
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height / 2));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} l " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                }
                            }
                            if (shape.shapeType.sti.is(StiOvalShapeType)) {
                                pp.service.pageStream.writeLine(geomWriter.getEllipseString(new Rectangle(pp.X, pp.Y, pp.Width, pp.Height)) + st);
                            }
                            if (shape.shapeType.sti.is(StiRoundedRectangleShapeType)) {
                                var rnd = shape.shapeType.sti.as(StiRoundedRectangleShapeType).round;
                                var side = pp.Width;
                                if (side > pp.Height)
                                    side = pp.Height;
                                var offs = Math.min(side, 70) * rnd;
                                var tmp = offs * (1 - pp.service.pdfCKT);
                                pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + offs));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height - offs));
                                pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} c", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height - tmp), pp.service.convertToString(pp.X + tmp), pp.service.convertToString(pp.Y + pp.Height), pp.service.convertToString(pp.X + offs), pp.service.convertToString(pp.Y + pp.Height));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width - offs), pp.service.convertToString(pp.Y + pp.Height));
                                pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} c", pp.service.convertToString(pp.X + pp.Width - tmp), pp.service.convertToString(pp.Y + pp.Height), pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height - tmp), pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height - offs));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + offs));
                                pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} c", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + tmp), pp.service.convertToString(pp.X + pp.Width - tmp), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X + pp.Width - offs), pp.service.convertToString(pp.Y));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + offs), pp.service.convertToString(pp.Y));
                                pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} c " + st, pp.service.convertToString(pp.X + tmp), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + tmp), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + offs));
                            }
                            if (shape.shapeType.sti.is(StiArrowShapeType)) {
                                var ssd = (shape.shapeType.sti.as(StiArrowShapeType)).direction;
                                var arrowW = (shape.shapeType.sti.as(StiArrowShapeType)).arrowWidth;
                                var arrowH = (shape.shapeType.sti.as(StiArrowShapeType)).arrowHeight;
                                var arw = pp.Width * arrowW;
                                var arh = pp.Height * arrowH;
                                if ((ssd == StiShapeDirection.Left) || (ssd == StiShapeDirection.Right)) {
                                    arw = pp.Height * arrowW;
                                    arh = pp.Width * arrowH;
                                }
                                if (arrowH == 0)
                                    arh = Math.min(pp.Width / 2, pp.Height / 2);
                                if (ssd == StiShapeDirection.Up) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X + arw), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arw), pp.service.convertToString(pp.Y + pp.Height - arh));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height - arh));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height - arh));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width - arw), pp.service.convertToString(pp.Y + pp.Height - arh));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width - arw), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l " + st, pp.service.convertToString(pp.X + arw), pp.service.convertToString(pp.Y));
                                }
                                if (ssd == StiShapeDirection.Down) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X + pp.Width - arw), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width - arw), pp.service.convertToString(pp.Y + arh));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + arh));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + arh));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arw), pp.service.convertToString(pp.Y + arh));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arw), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} l " + st, pp.service.convertToString(pp.X + pp.Width - arw), pp.service.convertToString(pp.Y + pp.Height));
                                }
                                if (ssd == StiShapeDirection.Left) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + arw));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arh), pp.service.convertToString(pp.Y + arw));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arh), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height / 2));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arh), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arh), pp.service.convertToString(pp.Y + pp.Height - arw));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height - arw));
                                    pp.service.pageStream.writeLine("{0} {1} l " + st, pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + arw));
                                }
                                if (ssd == StiShapeDirection.Right) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height - arw));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width - arh), pp.service.convertToString(pp.Y + pp.Height - arw));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width - arh), pp.service.convertToString(pp.Y + pp.Height));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height / 2));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width - arh), pp.service.convertToString(pp.Y));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width - arh), pp.service.convertToString(pp.Y + arw));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + arw));
                                    pp.service.pageStream.writeLine("{0} {1} l " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height - arw));
                                }
                            }
                            if (shape.shapeType.sti.is(StiOctagonShapeType)) {
                                var octagonShape = shape.shapeType.sti.as(StiOctagonShapeType);
                                var bevelx = (shape.report != null ? shape.report.unit.convertToHInches(octagonShape.bevel) : octagonShape.bevel) * pp.service.hiToTwips;
                                var bevely = bevelx;
                                if (octagonShape.autoSize) {
                                    bevelx = pp.Width / (2.414 * 1.414);
                                    bevely = pp.Height / (2.414 * 1.414);
                                }
                                if (bevelx > pp.Width / 2)
                                    bevelx = pp.Width / 2;
                                if (bevely > pp.Height / 2)
                                    bevely = pp.Height / 2;
                                pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X + bevelx), pp.service.convertToString(pp.Y));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width - bevelx), pp.service.convertToString(pp.Y));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + bevely));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width), pp.service.convertToString(pp.Y + pp.Height - bevely));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width - bevelx), pp.service.convertToString(pp.Y + pp.Height));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + bevelx), pp.service.convertToString(pp.Y + pp.Height));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height - bevely));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + bevely));
                                pp.service.pageStream.writeLine("{0} {1} l " + st, pp.service.convertToString(pp.X + bevelx), pp.service.convertToString(pp.Y));
                            }
                            if (shape.shapeType.sti.is(StiComplexArrowShapeType)) {
                                var restHeight = (pp.Width < pp.Height) ? pp.Width / 2 : pp.Height / 2;
                                var topBottomSpace = (pp.Height / 3.8);
                                var leftRightSpace = (pp.Width / 3.8);
                                var restWidth = (pp.Height < pp.Width) ? pp.Height / 2 : pp.Width / 2;
                                switch ((shape.shapeType.sti.as(StiComplexArrowShapeType)).direction) {
                                    case StiShapeDirection.Left:
                                    case StiShapeDirection.Right:
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height / 2));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + restHeight), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + restHeight), pp.service.convertToString(pp.Y + topBottomSpace));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - restHeight), pp.service.convertToString(pp.Y + topBottomSpace));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - restHeight), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y + pp.Height / 2));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - restHeight), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - restHeight), pp.service.convertToString(pp.Top - topBottomSpace));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + restHeight), pp.service.convertToString(pp.Top - topBottomSpace));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + restHeight), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + pp.Height / 2));
                                        break;
                                    case StiShapeDirection.Down:
                                    case StiShapeDirection.Up:
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + restWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y + restWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - leftRightSpace), pp.service.convertToString(pp.Y + restWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - leftRightSpace), pp.service.convertToString(pp.Top - restWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - restWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - restWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + leftRightSpace), pp.service.convertToString(pp.Top - restWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + leftRightSpace), pp.service.convertToString(pp.Y + restWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + restWidth));
                                        break;
                                }
                            }
                            if (shape.shapeType.sti.is(StiBentArrowShapeType)) {
                                var lineHeight = 0;
                                var arrowWidth = 0;
                                var space = 0;
                                if (pp.Height > pp.Width) {
                                    arrowWidth = pp.Width / 4;
                                    lineHeight = arrowWidth;
                                    space = arrowWidth / 2;
                                }
                                else {
                                    lineHeight = Math.floor(pp.Height / 4);
                                    arrowWidth = lineHeight;
                                    space = arrowWidth / 2;
                                }
                                switch ((shape.shapeType.sti.as(StiBentArrowShapeType)).direction) {
                                    case StiShapeDirection.Up:
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + lineHeight));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - (space + lineHeight)), pp.service.convertToString(pp.Y + lineHeight));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - (space + lineHeight)), pp.service.convertToString(pp.Top - arrowWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - arrowWidth * 2), pp.service.convertToString(pp.Top - arrowWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - arrowWidth), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - arrowWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - space), pp.service.convertToString(pp.Top - arrowWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - space), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                        break;
                                    case StiShapeDirection.Left:
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - space));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arrowWidth), pp.service.convertToString(pp.Top - space));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arrowWidth), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - arrowWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arrowWidth), pp.service.convertToString(pp.Top - arrowWidth * 2));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arrowWidth), pp.service.convertToString(pp.Top - arrowWidth - space));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - lineHeight), pp.service.convertToString(pp.Top - arrowWidth - space));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - lineHeight), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l h " + st, pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y));
                                        break;
                                    case StiShapeDirection.Down:
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + space), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + space), pp.service.convertToString(pp.Y + arrowWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + arrowWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arrowWidth), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arrowWidth * 2), pp.service.convertToString(pp.Y + arrowWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arrowWidth + space), pp.service.convertToString(pp.Y + arrowWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + arrowWidth + space), pp.service.convertToString(pp.Top - lineHeight));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - lineHeight));
                                        pp.service.pageStream.writeLine("{0} {1} l h " + st, pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top));
                                        break;
                                    case StiShapeDirection.Right:
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + space));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - arrowWidth), pp.service.convertToString(pp.Y + space));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - arrowWidth), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y + arrowWidth));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - arrowWidth), pp.service.convertToString(pp.Y + arrowWidth * 2));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - arrowWidth), pp.service.convertToString(pp.Y + arrowWidth + space));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + lineHeight), pp.service.convertToString(pp.Y + arrowWidth + space));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + lineHeight), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top));
                                        break;
                                }
                            }
                            if (shape.shapeType.sti.is(StiChevronShapeType)) {
                                var rest = (pp.Width > pp.Height) ? (pp.Height / 2) : (pp.Width / 2);
                                switch ((shape.shapeType.sti.as(StiChevronShapeType)).direction) {
                                    case StiShapeDirection.Right:
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + rest), pp.service.convertToString(pp.Top - pp.Height / 2));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - rest), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - pp.Height / 2));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - rest), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top));
                                        break;
                                    case StiShapeDirection.Left:
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + rest), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - pp.Height / 2));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + rest), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right - rest), pp.service.convertToString(pp.Top - pp.Height / 2));
                                        pp.service.pageStream.writeLine("{0} {1} l h " + st, pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top));
                                        break;
                                    case StiShapeDirection.Up:
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - rest));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - rest));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y + rest));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - rest));
                                        break;
                                    case StiShapeDirection.Down:
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Top - rest));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y + rest));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y));
                                        pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + rest));
                                        pp.service.pageStream.writeLine("{0} {1} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top));
                                        break;
                                }
                            }
                            if (shape.shapeType.sti.is(StiDivisionShapeType)) {
                                var restHeight = pp.Height / 3;
                                var offset = 4 * pp.service.hiToTwips;
                                pp.service.pageStream.writeLine(geomWriter.getRectString4(pp.X, pp.Y + restHeight + offset, pp.Width, restHeight - offset * 2) + st);
                                pp.service.pageStream.writeLine(geomWriter.getEllipseString4(pp.X + pp.Width / 2 - restHeight / 2, pp.Top - pp.service.hiToTwips - restHeight, restHeight, restHeight) + st);
                                pp.service.pageStream.writeLine(geomWriter.getEllipseString4(pp.X + pp.Width / 2 - restHeight / 2, pp.Y + 2 * pp.service.hiToTwips, restHeight, restHeight) + st);
                            }
                            if (shape.shapeType.sti.is(StiEqualShapeType)) {
                                var height = (pp.Height - (pp.Height / 6)) / 2;
                                pp.service.pageStream.writeLine(geomWriter.getRectString4(pp.X, pp.Top - height, pp.Width, height) + st);
                                pp.service.pageStream.writeLine(geomWriter.getRectString4(pp.X, pp.Y, pp.Width, height) + st);
                            }
                            if (shape.shapeType.sti.is(StiFlowchartCardShapeType)) {
                                pp.service.pageStream.writeLine("{0} {1} m {2} {3} l", pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y));
                                pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - pp.Height / 5), pp.service.convertToString(pp.X + pp.Width / 5), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top));
                            }
                            if (shape.shapeType.sti.is(StiFlowchartCollateShapeType)) {
                                switch ((shape.shapeType.sti.as(StiFlowchartCollateShapeType)).direction) {
                                    case StiShapeDirection.Down:
                                    case StiShapeDirection.Up:
                                        pp.service.pageStream.writeLine("{0} {1} m {2} {3} l {4} {5} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y + pp.Height / 2));
                                        pp.service.pageStream.writeLine("{0} {1} m {2} {3} l {4} {5} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y + pp.Height / 2), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y));
                                        break;
                                    case StiShapeDirection.Left:
                                    case StiShapeDirection.Right:
                                        pp.service.pageStream.writeLine("{0} {1} m {2} {3} l {4} {5} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y + pp.Height / 2));
                                        pp.service.pageStream.writeLine("{0} {1} m {2} {3} l {4} {5} l h " + st, pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y + pp.Height / 2), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top));
                                        break;
                                }
                            }
                            if (shape.shapeType.sti.is(StiFlowchartDecisionShapeType)) {
                                pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - pp.Height / 2));
                                pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - pp.Height / 2), pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - pp.Height / 2));
                            }
                            if (shape.shapeType.sti.is(StiFlowchartManualInputShapeType)) {
                                pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - pp.Height / 5));
                                pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - pp.Height / 5));
                            }
                            if (shape.shapeType.sti.is(StiFlowchartOffPageConnectorShapeType)) {
                                var restHeight = pp.Height / 5;
                                var restWidth = pp.Width / 5;
                                switch ((shape.shapeType.sti.as(StiFlowchartOffPageConnectorShapeType)).direction) {
                                    case StiShapeDirection.Down:
                                        pp.service.pageStream.writeLine("{0} {1} m {2} {3} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y + restHeight), pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + restHeight), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top));
                                        break;
                                    case StiShapeDirection.Up:
                                        pp.service.pageStream.writeLine("{0} {1} m {2} {3} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - restHeight));
                                        pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - restHeight), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                        break;
                                    case StiShapeDirection.Left:
                                        pp.service.pageStream.writeLine("{0} {1} m {2} {3} l", pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - pp.Height / 2), pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Top));
                                        break;
                                    case StiShapeDirection.Right:
                                        pp.service.pageStream.writeLine("{0} {1} m {2} {3} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - pp.Height / 2), pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top));
                                        break;
                                }
                            }
                            if (shape.shapeType.sti.is(StiFlowchartPreparationShapeType)) {
                                var restWidth = pp.Width / 5;
                                var restHeight = pp.Height / 5;
                                var xCenter = pp.Width / 2;
                                var yCenter = pp.Height / 2;
                                switch ((shape.shapeType.sti.as(StiFlowchartPreparationShapeType)).direction) {
                                    case StiShapeDirection.Left:
                                    case StiShapeDirection.Right:
                                        pp.service.pageStream.writeLine("{0} {1} m {2} {3} l {4} {5} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - yCenter), pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Top));
                                        pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - yCenter), pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - yCenter));
                                        break;
                                    case StiShapeDirection.Down:
                                    case StiShapeDirection.Up:
                                        pp.service.pageStream.writeLine("{0} {1} m {2} {3} l {4} {5} l", pp.service.convertToString(pp.X + xCenter), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - restHeight), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y + restHeight));
                                        pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.X + xCenter), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + restHeight), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - restHeight), pp.service.convertToString(pp.X + xCenter), pp.service.convertToString(pp.Top));
                                        break;
                                }
                            }
                            if (shape.shapeType.sti.is(StiFlowchartSortShapeType)) {
                                pp.service.pageStream.writeLine("{0} {1} m {2} {3} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - pp.Height / 2), pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Top));
                                pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - pp.Height / 2), pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - pp.Height / 2), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - pp.Height / 2));
                            }
                            if (shape.shapeType.sti.is(StiFrameShapeType)) {
                                var restWidth = pp.Width / 7;
                                var restHeight = pp.Height / 7;
                                pp.service.pageStream.writeLine("{0} {1} m {2} {3} l {4} {5} l {6} {7} l h", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                                pp.service.pageStream.writeLine("{0} {1} m {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Top - restHeight), pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Y + restHeight), pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Y + restHeight), pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Top - restHeight));
                            }
                            if (shape.shapeType.sti.is(StiMinusShapeType)) {
                                var restHeight = pp.Height / 3;
                                pp.service.pageStream.writeLine(geomWriter.getRectString4(pp.X, pp.Y + restHeight, pp.Width, restHeight) + st);
                            }
                            if (shape.shapeType.sti.is(StiMultiplyShapeType)) {
                                var restWidth = pp.Width / 4;
                                var restHeight = pp.Height / 4;
                                pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - restHeight));
                                pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l", pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Top - restHeight), pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - restHeight));
                                pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l", pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Top - pp.Height / 2), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y + restHeight), pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y + restHeight));
                                pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l h " + st, pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + restHeight), pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Top - pp.Height / 2));
                            }
                            if (shape.shapeType.sti.is(StiParallelogramShapeType)) {
                                var restWidth = pp.Width / 7;
                                var restHeight = pp.Height / 7;
                                pp.service.pageStream.writeLine("{0} {1} m {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X + pp.Width / 5), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right - pp.Width / 5), pp.service.convertToString(pp.Y));
                            }
                            if (shape.shapeType.sti.is(StiPlusShapeType)) {
                                var restWidth = pp.Width / 3;
                                var restHeight = pp.Height / 3;
                                pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Top));
                                pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l", pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Top - restHeight), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - restHeight), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y + restHeight));
                                pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l", pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Y + restHeight), pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Y + restHeight));
                                pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + restHeight), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - restHeight), pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Top - restHeight), pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Top));
                            }
                            if (shape.shapeType.sti.is(StiRegularPentagonShapeType)) {
                                var restTop = pp.Height / 2.6;
                                var restLeft = pp.Width / 5.5;
                                pp.service.pageStream.writeLine("{0} {1} m {2} {3} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - restTop), pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Top));
                                pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - restTop), pp.service.convertToString(pp.Right - restLeft), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X + restLeft), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - restTop));
                            }
                            if (shape.shapeType.sti.is(StiTrapezoidShapeType)) {
                                var rest = pp.Width / 4.75;
                                pp.service.pageStream.writeLine("{0} {1} m {2} {3} l {4} {5} l {6} {7} l h " + st, pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X + rest), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right - rest), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y));
                            }
                            if (shape.shapeType.sti.is(StiSnipSameSideCornerRectangleShapeType)) {
                                var restWidth = pp.Width / 7.2;
                                var restHeight = pp.Height / 4.6;
                                pp.service.pageStream.writeLine("{0} {1} m {2} {3} l {4} {5} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top - restHeight), pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Top));
                                pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l h " + st, pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - restHeight), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y));
                            }
                            if (shape.shapeType.sti.is(StiSnipDiagonalSideCornerRectangleShapeType)) {
                                var restWidth = pp.Width / 7.2;
                                var restHeight = pp.Height / 4.6;
                                pp.service.pageStream.writeLine("{0} {1} m {2} {3} l {4} {5} l", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right - restWidth), pp.service.convertToString(pp.Top), pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Top - restHeight));
                                pp.service.pageStream.writeLine("{0} {1} l {2} {3} l {4} {5} l h " + st, pp.service.convertToString(pp.Right), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X + restWidth), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y + restHeight));
                            }
                            pp.service.pageStream.writeLine("Q");
                        }
                        else {
                            var ir = imageResolution;
                            // using(Image image = shape.GetImage(ref imageResolution))
                            // {
                            //    WriteImageInfo(pp, ir);
                            // }
                        }
                    }
                };
                //#region RenderRoundedRectanglePrimitive
                StiPdfRenderPrimitives.renderRoundedRectanglePrimitive = function (pp) {
                    var mBorder = pp.Component.sti.as(IStiBorder);
                    if (mBorder != null) {
                        var border = new StiBorderSide(mBorder.border.color, mBorder.border.size, mBorder.border.style);
                        var primitive = pp.Component.sti.as(StiRoundedRectanglePrimitive);
                        if (primitive.style == StiPenStyle.None)
                            return;
                        var needPush = (mBorder.border.style != StiPenStyle.None) && (mBorder.border.style != StiPenStyle.Solid);
                        if (needPush) {
                            pp.service.pageStream.writeLine("q");
                            pp.service.pushColorToStack();
                        }
                        var offset = this.storeBorderSideData(border, pp);
                        var roundOffset = Math.min((pp.Width < pp.Height ? pp.Width : pp.Height), 100 * pp.Component.page.zoom) * primitive.round;
                        var roundOffset2 = roundOffset * (1 - pp.service.pdfCKT);
                        var x1 = pp.X - offset;
                        var x2 = pp.X + pp.Width + offset;
                        var xc = pp.X + pp.Width / 2;
                        var y1 = pp.Y - offset;
                        var y2 = pp.Y + pp.Height + offset;
                        //#region Draw single lines
                        if (primitive.leftSide) {
                            if (primitive.bottomSide) {
                                pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString((primitive.rightSide ? xc : x2)), pp.service.convertToString(y1));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(x1 + roundOffset), pp.service.convertToString(y1));
                                pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} c", pp.service.convertToString(x1 + roundOffset2), pp.service.convertToString(y1), pp.service.convertToString(x1), pp.service.convertToString(y1 + roundOffset2), pp.service.convertToString(x1), pp.service.convertToString(y1 + roundOffset));
                            }
                            else {
                                pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(x1), pp.service.convertToString(y1));
                            }
                            if (primitive.topSide) {
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(x1), pp.service.convertToString(y2 - roundOffset));
                                pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} c", pp.service.convertToString(x1), pp.service.convertToString(y2 - roundOffset2), pp.service.convertToString(x1 + roundOffset2), pp.service.convertToString(y2), pp.service.convertToString(x1 + roundOffset), pp.service.convertToString(y2));
                                pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString((primitive.rightSide ? xc : x2)), pp.service.convertToString(y2));
                            }
                            else {
                                pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(x1), pp.service.convertToString(y2));
                            }
                        }
                        if (primitive.rightSide) {
                            if (primitive.bottomSide) {
                                pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString((primitive.leftSide ? xc : x1)), pp.service.convertToString(y1));
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(x2 - roundOffset), pp.service.convertToString(y1));
                                pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} c", pp.service.convertToString(x2 - roundOffset2), pp.service.convertToString(y1), pp.service.convertToString(x2), pp.service.convertToString(y1 + roundOffset2), pp.service.convertToString(x2), pp.service.convertToString(y1 + roundOffset));
                            }
                            else {
                                pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(x2), pp.service.convertToString(y1));
                            }
                            if (primitive.topSide) {
                                pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(x2), pp.service.convertToString(y2 - roundOffset));
                                pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} c", pp.service.convertToString(x2), pp.service.convertToString(y2 - roundOffset2), pp.service.convertToString(x2 - roundOffset2), pp.service.convertToString(y2), pp.service.convertToString(x2 - roundOffset), pp.service.convertToString(y2));
                                pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString((primitive.leftSide ? xc : x1)), pp.service.convertToString(y2));
                            }
                            else {
                                pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(x2), pp.service.convertToString(y2));
                            }
                        }
                        if (primitive.topSide && !primitive.leftSide && !primitive.rightSide) {
                            pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(x1), pp.service.convertToString(y2));
                            pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(x2), pp.service.convertToString(y2));
                        }
                        if (primitive.bottomSide && !primitive.leftSide && !primitive.rightSide) {
                            pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(x1), pp.service.convertToString(y1));
                            pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(x2), pp.service.convertToString(y1));
                        }
                        //#endregion
                        if (border.style == StiPenStyle.Double) {
                            //#region Draw second lines
                            roundOffset -= offset * 2;
                            roundOffset2 = roundOffset * (1 - pp.service.pdfCKT);
                            var x3 = pp.X + offset;
                            var x4 = pp.X + pp.Width - offset;
                            var y3 = pp.Y + offset;
                            var y4 = pp.Y + pp.Height - offset;
                            if (primitive.leftSide) {
                                if (primitive.bottomSide) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString((primitive.rightSide ? xc : x2)), pp.service.convertToString(y3));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(x3 + roundOffset), pp.service.convertToString(y3));
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} c", pp.service.convertToString(x3 + roundOffset2), pp.service.convertToString(y3), pp.service.convertToString(x3), pp.service.convertToString(y3 + roundOffset2), pp.service.convertToString(x3), pp.service.convertToString(y3 + roundOffset));
                                }
                                else {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(x3), pp.service.convertToString(y1));
                                }
                                if (primitive.topSide) {
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(x3), pp.service.convertToString(y4 - roundOffset));
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} c", pp.service.convertToString(x3), pp.service.convertToString(y4 - roundOffset2), pp.service.convertToString(x3 + roundOffset2), pp.service.convertToString(y4), pp.service.convertToString(x3 + roundOffset), pp.service.convertToString(y4));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString((primitive.rightSide ? xc : x2)), pp.service.convertToString(y4));
                                }
                                else {
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(x3), pp.service.convertToString(y2));
                                }
                            }
                            if (primitive.rightSide) {
                                if (primitive.bottomSide) {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString((primitive.leftSide ? xc : x1)), pp.service.convertToString(y3));
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(x4 - roundOffset), pp.service.convertToString(y3));
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} c", pp.service.convertToString(x4 - roundOffset2), pp.service.convertToString(y3), pp.service.convertToString(x4), pp.service.convertToString(y3 + roundOffset2), pp.service.convertToString(x4), pp.service.convertToString(y3 + roundOffset));
                                }
                                else {
                                    pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(x4), pp.service.convertToString(y1));
                                }
                                if (primitive.topSide) {
                                    pp.service.pageStream.writeLine("{0} {1} l", pp.service.convertToString(x4), pp.service.convertToString(y4 - roundOffset));
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} c", pp.service.convertToString(x4), pp.service.convertToString(y4 - roundOffset2), pp.service.convertToString(x4 - roundOffset2), pp.service.convertToString(y4), pp.service.convertToString(x4 - roundOffset), pp.service.convertToString(y4));
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString((primitive.leftSide ? xc : x1)), pp.service.convertToString(y4));
                                }
                                else {
                                    pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(x4), pp.service.convertToString(y2));
                                }
                            }
                            if (primitive.topSide && !primitive.leftSide && !primitive.rightSide) {
                                pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(x1), pp.service.convertToString(y4));
                                pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(x2), pp.service.convertToString(y4));
                            }
                            if (primitive.bottomSide && !primitive.leftSide && !primitive.rightSide) {
                                pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(x1), pp.service.convertToString(y3));
                                pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(x2), pp.service.convertToString(y3));
                            }
                            //#endregion
                        }
                        if (needPush) {
                            pp.service.pageStream.writeLine("Q");
                            pp.service.popColorFromStack();
                        }
                    }
                };
                //#endregion
                StiPdfRenderPrimitives.renderCheckbox = function (pp, checkBoxValue, storeShading) {
                    if (storeShading === void 0) { storeShading = true; }
                    var checkbox = pp.Component.sti.as(StiCheckBox);
                    if (checkbox != null) {
                        // Get shape path
                        var shape = null;
                        switch (checkBoxValue ? checkbox.checkStyleForTrue : checkbox.checkStyleForFalse) {
                            case StiCheckStyle.Cross:
                                shape = "62.568 52.024 m 62.018 52.166 60.405 52.537 58.984 52.848 c 55.336 53.645 49.313 58.685 44.741 64.767 c 40.839 69.958 l 45.919 71.092 l \r\n" +
                                    "53.272 72.735 59.559 76.81 67.746 85.239 c 74.954 92.661 l 68.543 100.174 l 56.77 113.972 54.196 123.193 59.915 131.088 c 62.809 135.083 71.734 143.458 73.097 143.458 c \r\n" +
                                    "73.509 143.458 74.16 141.77 74.546 139.708 c 75.526 134.457 81.002 122.942 85.482 116.708 c 87.557 113.82 89.473 111.458 89.74 111.458 c \r\n" +
                                    "90.006 111.458 93.515 114.945 97.537 119.208 c 113.934 136.584 127.211 138.972 135.818 126.095 c 139.973 119.877 140.004 118.024 135.958 117.739 c \r\n" +
                                    "130.11 117.329 118.795 109.205 110.443 99.42 c 105.812 93.994 l 110.69 89.679 l 117.241 83.884 129.589 77.786 136.531 76.919 c \r\n" +
                                    "139.576 76.539 142.068 75.813 142.068 75.307 c 142.068 72.526 132.802 60.889 129.038 58.942 c 121.077 54.825 112.668 58.23 96.273 72.209 c \r\n" +
                                    "91.287 76.46 l 84.2 67.488 l 80.303 62.554 75.379 57.368 73.259 55.965 c 69.353 53.38 64.393 51.552 62.568 52.024 c h";
                                break;
                            case StiCheckStyle.Check:
                                shape = "60.972 37.503 m 51.173 63.277 43.562 76.623 35.37 82.397 c 30.912 85.54 l 33.664 88.435 l 37.539 92.513 43.698 95.935 48.566 96.713 c \r\n" +
                                    "52.426 97.33 53.024 97.093 57.102 93.334 c 59.763 90.882 63.368 85.726 66.269 80.223 c 68.899 75.234 71.18 71.153 71.337 71.153 c \r\n" +
                                    "71.493 71.153 73.65 74.19 76.13 77.903 c 96.259 108.044 129.683 141.214 157.565 158.718 c 166.414 164.274 l 168.677 161.643 l \r\n" +
                                    "170.941 159.012 l 163.178 152.717 l 139.859 133.81 108.017 94.486 89.043 61.164 c 82.362 49.432 81.87 48.851 73.952 43.345 c \r\n" +
                                    "69.45 40.214 64.908 37.04 63.858 36.292 c 62.149 35.074 61.848 35.2 60.972 37.503 c h";
                                break;
                            case StiCheckStyle.CrossRectangle:
                                shape = "24.153 97.958 m 24.153 170.458 l 98.653 170.458 l 173.153 170.458 l 173.153 97.958 l 173.153 25.458 l 98.653 25.458 l 24.153 25.458 l 24.153 97.958 l h \r\n" +
                                    "157.911 97.708 m 157.653 154.958 l 98.653 154.958 l 39.653 154.958 l 39.393 98.958 l 39.25 68.158 39.348 42.395 39.611 41.708 c \r\n" +
                                    "39.987 40.727 52.819 40.458 99.129 40.458 c 158.169 40.458 l 157.911 97.708 l h \r\n" +
                                    "67.337 54.521 m 65.513 54.912 62.41 56.378 60.442 57.778 c 57.123 60.14 48.153 70.186 48.153 71.541 c 48.153 71.87 50.57 72.68 53.525 73.342 c \r\n" +
                                    "60.71 74.95 67.272 79.277 75.328 87.718 c 82.003 94.713 l 75.624 102.027 l 64.931 114.288 61.644 123.705 65.472 131.108 c \r\n" +
                                    "67.054 134.168 78.562 145.458 80.098 145.458 c 80.556 145.458 81.245 143.77 81.63 141.708 c 82.611 136.457 88.086 124.942 92.567 118.708 c \r\n" +
                                    "94.642 115.82 96.558 113.458 96.824 113.458 c 97.091 113.458 100.6 116.945 104.622 121.208 c 121.019 138.584 134.296 140.972 142.903 128.095 c \r\n" +
                                    "147.058 121.877 147.089 120.024 143.043 119.739 c 137.213 119.33 124.806 110.39 117.127 101.066 c 113.226 96.33 113.155 96.112 114.876 94.198 c \r\n" +
                                    "118.066 90.648 128.579 83.654 133.847 81.578 c 136.682 80.461 141.285 79.244 144.077 78.873 c 146.868 78.503 149.153 77.878 149.153 77.484 c \r\n" +
                                    "149.153 75.37 140.777 64.275 137.501 62.048 c 129.107 56.344 120.869 59.278 103.358 74.209 c 98.372 78.46 l 91.285 69.488 l \r\n" +
                                    "81.563 57.18 74.76 52.928 67.337 54.521 c h";
                                break;
                            case StiCheckStyle.CheckRectangle:
                                shape = "19.915 96.5 m 19.915 169 l 91.857 169 l 163.8 169 l 170.357 173.111 l 176.914 177.223 l 178.882 174.861 l 179.963 173.563 180.864 172.217 180.882 171.872 c \r\n" +
                                    "180.9 171.526 178.44 169.334 175.415 167 c 169.915 162.757 l 169.915 93.378 l 169.915 24 l 94.915 24 l 19.915 24 l 19.915 96.5 l h \r\n" +
                                    "153.915 92.622 m 153.915 141.962 153.786 146.137 152.294 144.899 c 149.513 142.592 136.609 126.998 127.965 115.5 c 117.473 101.544 104.486 81.963 98.451 71 c \r\n" +
                                    "93.993 62.903 93.316 62.192 84.16 56 c 78.873 52.425 74.256 49.375 73.9 49.223 c 73.544 49.07 71.988 52.22 70.441 56.223 c \r\n" +
                                    "68.895 60.225 65.183 68.635 62.192 74.911 c 57.906 83.903 55.515 87.56 50.914 92.161 c 47.703 95.372 44.364 98 43.495 98 c \r\n" +
                                    "40.697 98 41.79 99.66 47.479 104.049 c 53.073 108.365 60.662 111.14 64.28 110.194 c 67.84 109.263 73.689 102.039 78.2 93.002 c \r\n" +
                                    "82.663 84.062 l 87.207 90.895 l 95.518 103.394 108.214 118.311 125.807 136.25 c 143.215 154 l 89.565 154 l 35.915 154 l 35.915 96.5 l \r\n" +
                                    "35.915 39 l 94.915 39 l 153.915 39 l 153.915 92.622 l h";
                                break;
                            case StiCheckStyle.CrossCircle:
                                shape = "83.347 26.864 m 61.07 31.95 42.193 47.128 32.202 67.986 c 23.401 86.36 23.68 110.034 32.919 128.958 c 41.882 147.315 60.868 162.86 80.847 168.201 c \r\n" +
                                    "91.083 170.936 112.112 170.628 121.812 167.6 c 147.999 159.425 167.881 138.673 173.432 113.721 c 175.869 102.768 175 85.662 171.452 74.743 c \r\n" +
                                    "164.795 54.256 145.804 35.792 124.126 28.729 c 117.735 26.647 113.94 26.133 102.847 25.845 c 93.814 25.61 87.363 25.947 83.347 26.864 c h \r\n" +
                                    "112.414 41.542 m 129.545 44.672 146.131 57.503 153.827 73.579 c 168.725 104.698 152.719 141.239 119.425 152.119 c 112.712 154.313 109.49 154.763 100.347 154.781 c \r\n" +
                                    "90.993 154.8 88.185 154.404 81.579 152.131 c 64.423 146.231 51.91 134.6 45.14 118.265 c 42.988 113.072 42.446 109.911 42.069 100.368 c \r\n" +
                                    "41.551 87.229 42.811 81.166 48.181 70.958 c 52.288 63.15 63.613 51.864 71.549 47.67 c 83.611 41.295 98.688 39.034 112.414 41.542 c h \r\n" +
                                    "69.097 66.583 m 66.21 69.342 63.847 71.942 63.847 72.361 c 63.847 72.78 69.506 78.671 76.422 85.451 c 88.996 97.78 l 76.198 110.607 l 63.4 123.434 l \r\n" +
                                    "68.336 128.446 l 71.051 131.202 73.641 133.458 74.091 133.458 c 74.542 133.458 80.666 127.846 87.7 120.988 c 100.49 108.517 l 104.919 113.071 l \r\n" +
                                    "107.354 115.575 113.31 121.259 118.154 125.701 c 126.961 133.777 l 132.308 128.496 l 137.656 123.215 l 124.694 110.658 l 111.733 98.1 l 124.866 84.939 l \r\n" +
                                    "137.999 71.779 l 132.815 67.118 l 129.964 64.555 127.11 62.458 126.474 62.458 c 125.837 62.458 119.93 67.858 113.347 74.458 c \r\n" +
                                    "106.765 81.058 100.96 86.458 100.449 86.458 c 99.938 86.458 93.856 80.857 86.933 74.013 c 74.347 61.567 l 69.097 66.583 l h";
                                break;
                            case StiCheckStyle.DotCircle:
                                shape = "81.653 29.406 m 59.375 34.493 40.499 49.67 30.507 70.529 c 21.706 88.903 21.985 112.576 31.224 131.5 c 40.187 149.857 59.173 165.402 79.153 170.743 c \r\n" +
                                    "89.388 173.479 110.417 173.17 120.117 170.142 c 146.304 161.968 166.186 141.215 171.737 116.263 c 174.174 105.311 173.305 88.205 169.757 77.285 c \r\n" +
                                    "163.1 56.798 144.109 38.334 122.431 31.271 c 116.04 29.189 112.245 28.675 101.153 28.387 c 92.119 28.152 85.668 28.49 81.653 29.406 c h \r\n" +
                                    "111.653 44.504 m 132.341 48.848 149.671 64.959 155.751 85.5 c 158.113 93.481 158.113 107.519 155.751 115.5 c 150.089 134.629 134.635 149.703 114.653 155.588 c \r\n" +
                                    "106.553 157.973 90.741 157.974 82.695 155.589 c 62.46 149.592 46.687 133.961 41.605 114.869 c 39.656 107.547 39.74 91.753 41.764 84.932 c \r\n" +
                                    "50.494 55.507 80.736 38.013 111.653 44.504 c h \r\n" +
                                    "90.005 77.33 m 76.55 82.362 69.825 98.176 75.898 110.5 c 78.035 114.836 83.045 119.856 87.653 122.277 c 93.231 125.208 104.066 125.204 109.705 122.27 c \r\n" +
                                    "127.735 112.887 128.781 89.485 111.62 79.428 c 106.047 76.162 95.789 75.166 90.005 77.33 c h";
                                break;
                            case StiCheckStyle.DotRectangle:
                                shape = "23.847 98.805 m 23.847 171.305 l 98.347 171.305 l 172.847 171.305 l 172.847 98.805 l 172.847 26.305 l 98.347 26.305 l 23.847 26.305 l 23.847 98.805 l h \r\n" +
                                    "157.847 98.813 m 157.847 156.321 l 98.597 156.063 l 39.347 155.805 l 39.089 98.555 l 38.831 41.305 l 98.339 41.305 l 157.847 41.305 l 157.847 98.813 l h \r\n" +
                                    "63.527 64.959 m 63.153 65.333 62.847 80.638 62.847 98.972 c 62.847 132.305 l 98.361 132.305 l 133.874 132.305 l 133.611 98.555 l 133.347 64.805 l \r\n" +
                                    "98.777 64.542 l 79.763 64.398 63.901 64.585 63.527 64.959 c h";
                                break;
                            case StiCheckStyle.NoneCircle:
                                shape = "83.5 29.406 m 61.222 34.493 42.346 49.67 32.355 70.529 c 23.554 88.903 23.832 112.576 33.071 131.5 c 42.034 149.857 61.02 165.402 81 170.743 c \r\n" +
                                    "91.235 173.479 112.265 173.17 121.965 170.142 c 148.151 161.968 168.034 141.215 173.585 116.263 c 176.022 105.311 175.152 88.205 171.605 77.285 c \r\n" +
                                    "164.948 56.798 145.957 38.334 124.278 31.271 c 117.887 29.189 114.092 28.675 103 28.387 c 93.966 28.152 87.515 28.49 83.5 29.406 c h \r\n" +
                                    "113.5 44.504 m 134.189 48.848 151.519 64.959 157.598 85.5 c 159.961 93.481 159.961 107.519 157.598 115.5 c 151.937 134.629 136.483 149.703 116.5 155.588 c \r\n" +
                                    "108.401 157.973 92.589 157.974 84.543 155.589 c 64.308 149.592 48.534 133.961 43.453 114.869 c 41.504 107.547 41.588 91.753 43.612 84.932 c \r\n" +
                                    "52.342 55.507 82.583 38.013 113.5 44.504 c h";
                                break;
                            case StiCheckStyle.NoneRectangle:
                                shape = "24.153 97.958 m 24.153 170.458 l 98.653 170.458 l 173.153 170.458 l 173.153 97.958 l 173.153 25.458 l 98.653 25.458 l 24.153 25.458 l 24.153 97.958 l h \r\n" +
                                    "157.911 97.708 m 157.653 154.958 l 98.653 154.958 l 39.653 154.958 l 39.393 98.958 l 39.25 68.158 39.348 42.395 39.611 41.708 c \r\n" +
                                    "39.987 40.727 52.819 40.458 99.129 40.458 c 158.169 40.458 l 157.911 97.708 l h";
                                break;
                        }
                        pp.service.pageStream.writeLine("q");
                        pp.service.pushColorToStack();
                        // Fill color
                        var tempColor = StiBrush.toColor(checkbox.textBrush);
                        if (tempColor.a != 0) {
                            pp.service.setNonStrokeColor(tempColor);
                        }
                        if (checkbox.textBrush.sti.is(StiGradientBrush) || checkbox.textBrush.sti.is(StiGlareBrush)) {
                            if (storeShading) {
                                pp.service.storeShadingData2(pp.X, pp.Y, pp.Width, pp.Height, checkbox.textBrush);
                            }
                            pp.service.pageStream.writeLine("/Pattern cs /P{0} scn", 1 + pp.service.shadingCurrent);
                        }
                        if (checkbox.textBrush.sti.is(StiHatchBrush)) {
                            var hBrush = checkbox.textBrush.sti.as(StiHatchBrush);
                            pp.service.pageStream.writeLine("/Cs1 cs /PH{0} scn", pp.service.getHatchNumber(hBrush) + 1);
                        }
                        // stroke color
                        pp.service.setStrokeColor(checkbox.contourColor);
                        pp.service.pageStream.writeLine("{0} w", pp.service.convertToString(checkbox.size));
                        pp.service.pageStream.writeLine("1 0 0 1 {0} {1} cm", pp.service.convertToString(pp.X + pp.Width / 2), pp.service.convertToString(pp.Y + pp.Height / 2));
                        var size = Math.min(pp.Width, pp.Height);
                        var scale = size / 200;
                        pp.service.pageStream.writeLine("{0} 0 0 {0} 0 0 cm", pp.service.convertToString(scale));
                        pp.service.pageStream.writeLine("1 0 0 1 -98 -98 cm");
                        pp.service.pageStream.writeLine(shape);
                        pp.service.pageStream.writeLine("B");
                        pp.service.pageStream.writeLine("Q");
                        pp.service.popColorFromStack();
                    }
                };
                StiPdfRenderPrimitives.getCheckBoxValue = function (checkbox) {
                    var checkBoxValue = null;
                    if ((checkbox != null) && (checkbox.checkedValue != null)) {
                        checkBoxValue = false;
                        var checkedValueStr = checkbox.checkedValue.toString().trim().toLowerCase();
                        var strs = checkbox.values.split("/");
                        if (strs.length == 1)
                            strs = checkbox.values.split(";");
                        if (strs.length == 1)
                            strs = checkbox.values.split(",");
                        if (strs != null && strs.length > 0) {
                            var firstValue = strs[0].trim().toLowerCase();
                            checkBoxValue = checkedValueStr == firstValue;
                        }
                    }
                    return checkBoxValue;
                };
                return StiPdfRenderPrimitives;
            }());
            Export.StiPdfRenderPrimitives = StiPdfRenderPrimitives;
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
            var IStiTextBrush = Stimulsoft.Report.Components.IStiTextBrush;
            var IStiText = Stimulsoft.Report.Components.IStiText;
            var IStiTextHorAlignment = Stimulsoft.Report.Components.IStiTextHorAlignment;
            var IStiVertAlignment = Stimulsoft.Report.Components.IStiVertAlignment;
            var IStiTextOptions = Stimulsoft.Report.Components.IStiTextOptions;
            var IStiFont = Stimulsoft.Report.Components.IStiFont;
            var StiText = Stimulsoft.Report.Components.StiText;
            var StiTextHorAlignment = Stimulsoft.Base.Drawing.StiTextHorAlignment;
            var StiVertAlignment = Stimulsoft.Base.Drawing.StiVertAlignment;
            var Color = Stimulsoft.System.Drawing.Color;
            var StiBrush = Stimulsoft.Base.Drawing.StiBrush;
            var StiGradientBrush = Stimulsoft.Base.Drawing.StiGradientBrush;
            var StiGlareBrush = Stimulsoft.Base.Drawing.StiGlareBrush;
            var StiHatchBrush = Stimulsoft.Base.Drawing.StiHatchBrush;
            var StringBuilder = Stimulsoft.System.Text.StringBuilder;
            var Char = Stimulsoft.System.Char;
            var Matrix = Stimulsoft.System.Drawing.Drawing2D.Matrix;
            var StiPdfRenderText = /** @class */ (function () {
                function StiPdfRenderText() {
                }
                StiPdfRenderText.renderText = function (pp) {
                    var mTextBrush = pp.Component.sti.as(IStiTextBrush);
                    var text = pp.Component.sti.as(IStiText);
                    var textOpt = pp.Component.sti.as(IStiTextOptions);
                    var mTextHorAlign = pp.Component.sti.as(IStiTextHorAlignment);
                    var mVertAlign = pp.Component.sti.as(IStiVertAlignment);
                    var textComp = pp.Component.sti.as(StiText);
                    var wordWrap = (textOpt != null) && textOpt.textOptions.wordWrap;
                    var needWidthAlign = (mTextHorAlign != null) && (mTextHorAlign.horAlignment == StiTextHorAlignment.Width);
                    var needAnnots = pp.service.haveAnnots && textComp.editable;
                    var useRightToLeft = ((textOpt != null) && (textOpt.textOptions != null) && (textOpt.textOptions.rightToLeft));
                    var annotText = null;
                    var linesCount = 0;
                    var textAngle = 0;
                    var useWysiwyg = textComp.textQuality == Stimulsoft.Report.Components.StiTextQuality.Wysiwyg;
                    if (needWidthAlign)
                        wordWrap = true;
                    if (text != null) {
                        if (!needAnnots) {
                            pp.service.pageStream.writeLine("q");
                            pp.service.pushColorToStack();
                            pp.service.pageStream.writeLine("{0} {1} {2} {3} re W n", pp.service.convertToString(pp.X), pp.service.convertToString(pp.Y), pp.service.convertToString(pp.Width), pp.service.convertToString(pp.Height));
                        }
                        // set text color
                        var textColor = Color.transparent;
                        if (mTextBrush != null) {
                            textColor = StiBrush.toColor(mTextBrush.textBrush);
                            pp.service.setNonStrokeColor(textColor);
                            pp.service.storeShadingData2(pp.X, pp.Y, pp.Width, pp.Height, mTextBrush.textBrush);
                            if (mTextBrush.textBrush.sti.is(StiGradientBrush) || mTextBrush.textBrush.sti.is(StiGlareBrush)) {
                                pp.service.pageStream.writeLine("/Pattern cs /P{0} scn", 1 + pp.service.shadingCurrent);
                            }
                            if (mTextBrush.textBrush.sti.is(StiHatchBrush)) {
                                var hBrush = mTextBrush.textBrush.sti.as(StiHatchBrush);
                                pp.service.pageStream.writeLine("/Cs1 cs /PH{0} scn", pp.service.getHatchNumber(hBrush) + 1);
                            }
                            if (needAnnots) {
                                var seo = pp.service.annotsArray[pp.service.annotsCurrent];
                                seo.FontColor = textColor;
                            }
                        }
                        // calculate font parameters
                        var sizeInPt = 1;
                        var mFont = pp.Component.sti.as(IStiFont);
                        if (mFont != null)
                            sizeInPt = (mFont.font.sizeInPoints);
                        var cf = 1; // StiDpiHelper.GraphicsScale;
                        // let fontASC: number = sizeInPt * this.fontCorrectValue * this.pdfFont.ASC / 1000 * cf;
                        // let fontDESC: number = sizeInPt *this.fontCorrectValue * this.pdfFont.DESC / 1000 * cf;
                        var fonttmASC = sizeInPt * this.fontCorrectValue * pp.service.pdfFont.tmASC / 1000 * cf;
                        var fonttmDESC = sizeInPt * this.fontCorrectValue * pp.service.pdfFont.tmDESC / 1000 * (-1) * cf;
                        var fonttmExternal = sizeInPt * this.fontCorrectValue * pp.service.pdfFont.tmExternal / 1000 * cf;
                        var fontUnderscoreSize = sizeInPt * this.fontCorrectValue * pp.service.pdfFont.UnderscoreSize / 1000 * cf;
                        var fontUnderscorePosition = sizeInPt * this.fontCorrectValue * pp.service.pdfFont.UnderscorePosition / 1000 * cf;
                        var fontStrikeoutSize = sizeInPt * this.fontCorrectValue * pp.service.pdfFont.StrikeoutSize / 1000 * cf;
                        var fontStrikeoutPosition = sizeInPt * this.fontCorrectValue * pp.service.pdfFont.StrikeoutPosition / 1000 * cf;
                        var fontLineHeight = (fonttmASC - fonttmDESC + fonttmExternal) * textComp.lineSpacing;
                        var fontAscF = fonttmASC;
                        var fontDescF = fonttmDESC;
                        // calculate text coordinates
                        var margins = textComp.margins;
                        var marginL = this.hiToTwips * margins.left;
                        var marginR = this.hiToTwips * margins.right;
                        var marginT = this.hiToTwips * margins.top;
                        var marginB = this.hiToTwips * margins.bottom;
                        var textX = pp.X + marginL;
                        var textY = pp.Y + marginB;
                        var textW = pp.Width - marginL - marginR;
                        var textH = pp.Height - marginT - marginB;
                        if (needAnnots) {
                            textX -= pp.X;
                            textY -= pp.Y;
                        }
                        var correctX = 0.85;
                        var correctY = 0.85;
                        // correction of coordinates for border
                        textX += correctX - 0.5;
                        textW -= correctX * 2;
                        textY += correctY + 0.7;
                        textH -= correctY * 2;
                        var textQualityOffset = pp.service.pdfFont.Widths[0] / 2 * 0.99;
                        if (textComp.textQuality != Stimulsoft.Report.Components.StiTextQuality.Standard) {
                            textQualityOffset = textQualityOffset * 0.7;
                        }
                        var halfSpaceOffset = textQualityOffset * (sizeInPt * this.fontCorrectValue) / 1000;
                        textX += halfSpaceOffset;
                        textW -= halfSpaceOffset * 2;
                        var st = text.text;
                        if (st == null)
                            st = "";
                        st = pp.service.stringReplace(st, "\r", "");
                        st = pp.service.stringReplace(st, "\x1f", "");
                        if (needAnnots) {
                            annotText = pp.service.stringReplace(text.text, "\n", "");
                        }
                        if ((textW > 0) && (st.length > 0)) {
                            // calculate rotating angle
                            var normTextX = textX;
                            var normTextY = textY;
                            var normTextW = textW;
                            var normTextH = textH;
                            if (textOpt != null) {
                                textAngle = textOpt.textOptions.angle;
                                if (textAngle != 0) {
                                    if (((textAngle > 45) && (textAngle < 135)) || ((textAngle > 225) && (textAngle < 315))) {
                                        var tempValue = textW;
                                        textW = textH;
                                        textH = tempValue;
                                    }
                                    textX = -textW / 2;
                                    textY = -textH / 2;
                                }
                            }
                            var stringList = Export.StiExportUtils.splitString(st, false);
                            if (wordWrap) {
                                for (var indexLine = 0; indexLine < stringList.length; indexLine++) {
                                    var stt = stringList[indexLine];
                                    if (stt.length < 2)
                                        continue;
                                    // remake string with bidiconvert
                                    var sbt = new StringBuilder();
                                    var indexChar = 0;
                                    while (indexChar < stt.length) {
                                        if (Char.isWhitespace(stt, indexChar)) {
                                            sbt.append(stt.charAt(indexChar));
                                            indexChar++;
                                        }
                                        else {
                                            var sbtWord = new StringBuilder();
                                            while ((indexChar < stt.length) && !Char.isWhitespace(stt, indexChar)) {
                                                sbtWord.append(stt.charAt(indexChar));
                                                indexChar++;
                                            }
                                            var sbtWordBidi = pp.service.bidi.convert(sbtWord, false); // need add parameter - bool reverseString
                                            sbt.append(sbtWordBidi);
                                            var lenWord = sbtWord.length - sbtWordBidi.length;
                                            if (lenWord > 0) {
                                                sbt.append(StiString.repeat(String.fromCharCode(0), lenWord));
                                            }
                                        }
                                    }
                                    var charr = [];
                                    var stsbt = sbt.toString();
                                    for (var tempIndex = 0; tempIndex < stt.length; tempIndex++) {
                                        charr[tempIndex] = pp.service.pdfFont.UnicodeMap[stsbt.charCodeAt(tempIndex)];
                                    }
                                    var summarr = Array.create(Number, stt.length);
                                    var wordarr = Array.create(Number, stt.length);
                                    var wordCounter = 0;
                                    var summ = 0;
                                    for (var index = 0; index < charr.length; index++) {
                                        if (charr[index] >= 32)
                                            summ += pp.service.pdfFont.Widths[charr[index] - 32];
                                        if (charr[index] == 9) // \t
                                            summ += this.getTabsSize(textOpt, sizeInPt, summ + textQualityOffset) + textQualityOffset;
                                        summarr[index] = Math.trunc(summ);
                                        if ((this.isWordWrapSymbol(stsbt, index)) && (index > 0)) {
                                            wordCounter++;
                                        }
                                        wordarr[index] = wordCounter;
                                    }
                                    var summf = summ * (sizeInPt * this.fontCorrectValue) / 1000;
                                    // line is too long and have more than one word
                                    if (summf > textW) {
                                        var index = stt.length - 1;
                                        var textWint = Math.trunc(textW * 1000 / (sizeInPt * this.fontCorrectValue));
                                        while ((summarr[index] > textWint) && (index > 0))
                                            index--;
                                        // check in which word; if not first - find the beginnning of the word, otherwise - the end of the word
                                        var index2 = index;
                                        if (wordarr[index] > 0) {
                                            if (wordarr[index] != wordarr[index + 1]) {
                                                index2 = index++;
                                                while (Char.isWhitespace(stsbt, index) && stsbt.charAt(index) != "\t")
                                                    index++; // TrimEnd => no check index++
                                            }
                                            else {
                                                while (!this.isWordWrapSymbol(stsbt, index))
                                                    index--;
                                                index2 = index - 1;
                                                while ((Char.isWhitespace(stsbt, index2)) && (index2 > 0))
                                                    index2--;
                                                while (Char.isWhitespace(stsbt, index) && stsbt.charAt(index) != "\t")
                                                    index++;
                                            }
                                        }
                                        else {
                                            index++;
                                        }
                                        // this block must be optimized - on long text may be very slow (many pass on long line)
                                        if (needWidthAlign) {
                                            stringList[indexLine] = stt.substr(0, index2 + 1) + String.fromCharCode(7);
                                        }
                                        else {
                                            stringList[indexLine] = stt.substr(0, index2 + 1);
                                        }
                                        stringList.insert(indexLine + 1, stt.substr(index, stt.length - index).sti.trimStart(" "));
                                    }
                                }
                            }
                            linesCount = stringList.length;
                            var trimCountLines = -1;
                            // if (textOpt != null && textOpt.textOptions.trimming != StringTrimming.None) {
                            //    double trimCountLinesDouble = textH / fontLineHeight;
                            //    trimCountLines = (int)trimCountLinesDouble;
                            //    if (trimCountLinesDouble > trimCountLines) trimCountLines++;
                            //    if (trimCountLines < 1) trimCountLines = 1;
                            //    if (trimCountLines < linesCount) linesCount = trimCountLines;
                            // }
                            // mapping Unicode symbols and BidiConvert
                            for (var indexLine = 0; indexLine < stringList.length; indexLine++) {
                                var stt = stringList[indexLine];
                                var stTemp = pp.service.bidi.convert(new StringBuilder(stt), useRightToLeft).toString();
                                var sbTemp = new StringBuilder();
                                for (var index = 0; index < stTemp.length; index++) {
                                    sbTemp.append(String.fromCharCode(pp.service.pdfFont.UnicodeMap[stTemp.charCodeAt(index)]));
                                }
                                stringList[indexLine] = sbTemp.toString();
                            }
                            // VertAlign
                            if (mVertAlign != null) {
                                var lineHeight = fontLineHeight;
                                var textHeight = linesCount * lineHeight;
                                var vertAlignment = mVertAlign.vertAlignment;
                                if ((textAngle != 0) && (textAngle != 90) && (textAngle != 180) && (textAngle != 270)) {
                                    vertAlignment = StiVertAlignment.Center;
                                }
                                if (vertAlignment == StiVertAlignment.Top) {
                                    textY += (textH - textHeight) + (lineHeight - fontAscF);
                                }
                                if (vertAlignment == StiVertAlignment.Center) {
                                    textY += (textH - textHeight) / 2 + (lineHeight - fontAscF);
                                }
                                if (vertAlignment == StiVertAlignment.Bottom) {
                                    textY += (lineHeight - fontAscF);
                                }
                            }
                            pp.service.pageStream.writeLine("BT");
                            // write text
                            var lastTextLineX = 0;
                            var lastTextLineY = 0;
                            var underlineArray = Array.create(Number, stringList.length, 3);
                            var matrix = null;
                            if (textAngle != 0) {
                                var AngleInRadians = textAngle * Math.PI / 180;
                                matrix = new Matrix(Math.cos(AngleInRadians), Math.sin(AngleInRadians), -Math.sin(AngleInRadians), Math.cos(AngleInRadians), (normTextX + normTextW / 2), (normTextY + normTextH / 2));
                                if (!((pp.service.pdfFont.NeedSyntItalic) && (mFont != null) && (mFont.font.italic))) {
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} Tm", pp.service.convertToString(matrix.elements[0]), pp.service.convertToString(matrix.elements[1]), pp.service.convertToString(matrix.elements[2]), pp.service.convertToString(matrix.elements[3]), pp.service.convertToString(matrix.elements[4]), pp.service.convertToString(matrix.elements[5]));
                                }
                            }
                            if ((pp.service.pdfFont.NeedSyntBold) && (mFont != null) && (mFont.font.bold)) {
                                pp.service.pageStream.writeLine("{0} w 2 Tr", pp.service.convertToString(this.boldFontStrokeWidthValue * sizeInPt, 3));
                                pp.service.setStrokeColor(textColor);
                            }
                            for (var indexLine = 0; indexLine < linesCount; indexLine++) {
                                // calculate text line length in pt
                                var stt = stringList[indexLine];
                                var tabsArr = Array.create(Number, stt.length);
                                var numTabs = 0;
                                var summ = 0;
                                var trimSumm = 0;
                                var trimWidth = textW * 1000 / (sizeInPt * this.fontCorrectValue);
                                var trimCharWidth = pp.service.pdfFont.Widths[pp.service.pdfFont.UnicodeMap["…".charCodeAt(0)]];
                                var trimIndex = 0;
                                for (var index = 0; index < stt.length; index++) {
                                    var charrSym = stt.charCodeAt(index);
                                    if (charrSym >= 32) {
                                        summ += pp.service.pdfFont.Widths[charrSym - 32];
                                    }
                                    if (charrSym == 9) {
                                        var tabSize = this.getTabsSize(textOpt, sizeInPt, summ);
                                        summ += tabSize;
                                        tabsArr[numTabs++] = tabSize;
                                    }
                                    if (summ + trimCharWidth < trimWidth) {
                                        trimSumm = summ;
                                        trimIndex = index;
                                    }
                                }
                                summ = summ * (sizeInPt * this.fontCorrectValue) / 1000;
                                if ((trimCountLines != -1) && (((indexLine == linesCount - 1) && (trimCountLines < stringList.length)) || (summ > textW))) {
                                    // "…" trimming надо доделать
                                    stt = stt.substr(0, trimIndex) + String.fromCharCode(pp.service.pdfFont.UnicodeMap["…".charCodeAt(0)]);
                                    summ = (trimSumm + trimCharWidth) * (sizeInPt * this.fontCorrectValue) / 1000;
                                }
                                if (pp.service.useUnicodeMode) {
                                    //#region convert to hex
                                    var sbt = new StringBuilder();
                                    for (var index = 0; index < stt.length; index++) {
                                        if (index % 121 == 120) {
                                            sbt.appendLine("\r");
                                        }
                                        var code = stt.charCodeAt(index);
                                        if ((code == 32) || (code == 9) || (code == 7)) {
                                            sbt.append(stt.charAt(index));
                                        }
                                        else {
                                            var glyph = pp.service.pdfFont.GlyphList[code];
                                            if (glyph == 0xFFFF)
                                                glyph = 0x0000;
                                            sbt.appendFormat("{0:X4}", glyph);
                                        }
                                    }
                                    stt = sbt.toString();
                                    //#endregion
                                }
                                else {
                                    stt = Export.StiPdfExportService.convertToEscapeSequence(stt);
                                }
                                var textLineX = textX;
                                var textLineY = textY + fontLineHeight * (linesCount - indexLine - 1);
                                var isTextHorAlignmentWidth = false;
                                // HorAlign
                                var useSpaceWidth = false;
                                if (mTextHorAlign != null) {
                                    var horAlign = mTextHorAlign.horAlignment;
                                    if (needWidthAlign) {
                                        if ((stt.length > 0) && (stt.charCodeAt(stt.length - 1) === 7)) {
                                            stt = stt.substr(0, stt.length - 1);
                                        }
                                        else {
                                            horAlign = StiTextHorAlignment.Left;
                                        }
                                    }
                                    if (textOpt != null && textOpt.textOptions != null && textOpt.textOptions.rightToLeft) {
                                        if (horAlign == StiTextHorAlignment.Left)
                                            horAlign = StiTextHorAlignment.Right;
                                        else if (horAlign == StiTextHorAlignment.Right)
                                            horAlign = StiTextHorAlignment.Left;
                                    }
                                    // left justify - not need any offset
                                    if (horAlign == StiTextHorAlignment.Center) {
                                        textLineX += (textW - summ) / 2;
                                    }
                                    if (horAlign == StiTextHorAlignment.Right) {
                                        textLineX += textW - summ;
                                    }
                                    if (horAlign == StiTextHorAlignment.Width) {
                                        // calculate width align
                                        var numSpaces = 0;
                                        for (var spaceIndex = 0; spaceIndex < stt.length; spaceIndex++) {
                                            if (stt.charCodeAt(spaceIndex) === 32)
                                                numSpaces++;
                                        }
                                        if ((numSpaces > 0) && ((indexLine != stringList.length - 1) || (useWysiwyg && summ > textW))) {
                                            useSpaceWidth = true;
                                            var spaceOffset = ((textW - summ) / numSpaces) * 1000 / (sizeInPt * this.fontCorrectValue);
                                            if (spaceOffset > 0 || useWysiwyg) {
                                                isTextHorAlignmentWidth = true;
                                                spaceOffset += pp.service.pdfFont.Widths[0];
                                                if (spaceOffset < pp.service.pdfFont.Widths[0] * 0.5)
                                                    spaceOffset = pp.service.pdfFont.Widths[0] * 0.5;
                                                var sbSpace = new StringBuilder((pp.service.useUnicodeMode ? "<" : "("));
                                                for (var charIndex = 0; charIndex < stt.length; charIndex++) {
                                                    if (stt.charCodeAt(charIndex) === 32) {
                                                        if (pp.service.useUnicodeMode) {
                                                            sbSpace.append(">-" + pp.service.convertToString(spaceOffset) + "<");
                                                        }
                                                        else {
                                                            sbSpace.append(")-" + pp.service.convertToString(spaceOffset) + "(");
                                                        }
                                                    }
                                                    else {
                                                        sbSpace.append(stt[charIndex]);
                                                    }
                                                }
                                                sbSpace.append((pp.service.useUnicodeMode ? ">" : ")"));
                                                stt = sbSpace.toString();
                                            }
                                        }
                                    }
                                }
                                // write tabs offset
                                if (numTabs > 0) {
                                    var currentTab = 0;
                                    var sbTabs = new StringBuilder();
                                    if (useSpaceWidth == false) {
                                        sbTabs.append((pp.service.useUnicodeMode ? "<" : "("));
                                    }
                                    for (var charIndex = 0; charIndex < stt.length; charIndex++) {
                                        if (stt[charIndex] == "\t") {
                                            var tabOffset = tabsArr[currentTab++];
                                            if (pp.service.useUnicodeMode) {
                                                sbTabs.append(">-" + pp.service.convertToString(tabOffset) + "<");
                                            }
                                            else {
                                                sbTabs.append(")-" + pp.service.convertToString(tabOffset) + "(");
                                            }
                                        }
                                        else {
                                            sbTabs.append(stt[charIndex]);
                                        }
                                    }
                                    if (useSpaceWidth == false) {
                                        sbTabs.append((pp.service.useUnicodeMode ? ">" : ")"));
                                    }
                                    stt = sbTabs.toString();
                                }
                                if (pp.service.useUnicodeMode) {
                                    stt = pp.service.stringReplace(stt, " ", pp.service.pdfFont.GlyphList[32].toString(16).sti.padLeft(4, "0")).sti.replaceAll("\a", "0000");
                                }
                                // prepare text line to write
                                var needChildFonts = pp.service.pdfFont.ChildFontsMap != null;
                                var currentChildFont = 0;
                                var charr = Array.create(Number, stt.length);
                                var warpPoints = new Array();
                                for (var tempIndex = 0; tempIndex < stt.length; tempIndex++) {
                                    var ch = stt.charCodeAt(tempIndex);
                                    charr[tempIndex] = ch;
                                    var isWarp = false;
                                    if (ch == 13) {
                                        warpPoints.add(tempIndex);
                                        isWarp = true;
                                    }
                                    if (needChildFonts) {
                                        var symb = pp.service.pdfFont.UnicodeMapBack[ch];
                                        if (ch == 92) {
                                            symb = pp.service.pdfFont.UnicodeMapBack[stt.charCodeAt(tempIndex + 1)];
                                        }
                                        var tempChildFont = pp.service.pdfFont.ChildFontsMap[symb];
                                        if (symb < 64) {
                                            if (tempIndex > 0) {
                                                tempChildFont = currentChildFont;
                                            }
                                            else {
                                                if (stt.length > 1)
                                                    tempChildFont = pp.service.pdfFont.ChildFontsMap[pp.service.pdfFont.UnicodeMapBack[stt.charCodeAt(1)]];
                                            }
                                        }
                                        if (ch != 92) {
                                            charr[tempIndex] = pp.service.pdfFont.fonts[tempChildFont].UnicodeMap[symb];
                                        }
                                        if (tempChildFont != currentChildFont && !isWarp && tempIndex != 0) {
                                            warpPoints.add(tempIndex);
                                        }
                                        currentChildFont = tempChildFont;
                                    }
                                }
                                warpPoints.add(stt.length);
                                underlineArray[indexLine][0] = textLineX;
                                underlineArray[indexLine][1] = textLineY;
                                underlineArray[indexLine][2] = summ;
                                if ((pp.service.pdfFont.NeedSyntItalic) && (mFont != null) && (mFont.font.italic)) {
                                    var matrix2 = new Matrix(1, 0, this.italicAngleTanValue, 1, textLineX, textLineY);
                                    if (matrix != null) {
                                        // matrix2.multiply(matrix, MatrixOrder.Append);
                                        matrix2.multiply(matrix2);
                                    }
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} Tm", pp.service.convertToString(matrix2.elements[0]), pp.service.convertToString(matrix2.elements[1]), pp.service.convertToString(matrix2.elements[2]), pp.service.convertToString(matrix2.elements[3]), pp.service.convertToString(matrix2.elements[4]), pp.service.convertToString(matrix2.elements[5]));
                                }
                                else {
                                    pp.service.pageStream.writeLine("{0} {1} Td", pp.service.convertToString(textLineX - lastTextLineX), pp.service.convertToString(textLineY - lastTextLineY));
                                    lastTextLineX = textLineX;
                                    lastTextLineY = textLineY;
                                }
                                var startPoint = 0;
                                for (var indexWarpPoint = 0; indexWarpPoint < warpPoints.length; indexWarpPoint++) {
                                    if (needChildFonts && stt.length > 0) {
                                        var posCharToGetFont = (stt.charCodeAt(startPoint) < 64) && (stt.length > startPoint + 1) ? startPoint + 1 : startPoint;
                                        var tempChildFont = pp.service.pdfFont.ChildFontsMap[pp.service.pdfFont.UnicodeMapBack[stt.charCodeAt(posCharToGetFont)]];
                                        pp.service.pageStream.writeLine("/F{0} {1} Tf", tempChildFont, pp.service.convertToString(sizeInPt * this.fontCorrectValue, this.precision_digits_font));
                                    }
                                    var warpPoint = warpPoints[indexWarpPoint];
                                    var warpLength = warpPoint - startPoint;
                                    if (warpLength > 0) {
                                        if (isTextHorAlignmentWidth || (numTabs > 0)) {
                                            pp.service.pageStream.writeString("[");
                                            if (indexWarpPoint > 0)
                                                pp.service.pageStream.writeString(pp.service.useUnicodeMode ? "<" : "(");
                                            pp.service.pageStream.write(charr, startPoint, warpLength);
                                            if (indexWarpPoint < warpPoints.length - 1)
                                                pp.service.pageStream.writeString(pp.service.useUnicodeMode ? ">" : ")");
                                            pp.service.pageStream.writeLine("] TJ");
                                        }
                                        else {
                                            pp.service.pageStream.writeString((pp.service.useUnicodeMode ? "<" : "("));
                                            pp.service.pageStream.write(charr, startPoint, warpLength);
                                            pp.service.pageStream.writeLine("{0} Tj", (pp.service.useUnicodeMode ? ">" : ")"));
                                        }
                                    }
                                    startPoint = warpPoint;
                                    if (warpPoint < charr.length - 1 && charr[warpPoint] == 13)
                                        startPoint++;
                                }
                            }
                            if ((pp.service.pdfFont.NeedSyntBold) && (mFont != null) && (mFont.font.bold)) {
                                pp.service.pageStream.writeLine("0 Tr");
                            }
                            pp.service.pageStream.writeLine("ET");
                            // underline text
                            if ((mFont != null) && (mFont.font.underline)) {
                                pp.service.pageStream.writeLine("q");
                                pp.service.pushColorToStack();
                                var underscoreSize = sizeInPt * 0.07;
                                var underscorePosition = -sizeInPt * 0.1;
                                if (pp.service.pdfFont.UnderscoreSize != 0) {
                                    underscoreSize = fontUnderscoreSize;
                                    underscorePosition = fontUnderscorePosition;
                                }
                                if (underscoreSize < 0.1)
                                    underscoreSize = 0.1;
                                pp.service.pageStream.writeLine("{0} w", pp.service.convertToString(underscoreSize));
                                if (textAngle != 0) {
                                    var AngleInRadians = textAngle * Math.PI / 180;
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} cm", pp.service.convertToString(Math.cos(AngleInRadians)), pp.service.convertToString(Math.sin(AngleInRadians)), pp.service.convertToString(-Math.sin(AngleInRadians)), pp.service.convertToString(Math.cos(AngleInRadians)), pp.service.convertToString(normTextX + normTextW / 2), pp.service.convertToString(normTextY + normTextH / 2));
                                }
                                if (mTextBrush != null) {
                                    // tempColor = StiBrush.ToColor(mTextBrush.TextBrush);
                                    pp.service.setStrokeColor(textColor);
                                }
                                for (var tempIndex = 0; tempIndex < stringList.length; tempIndex++) {
                                    if (underlineArray[tempIndex][2] != 0) {
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(underlineArray[tempIndex][0]), pp.service.convertToString(underlineArray[tempIndex][1] + underscorePosition));
                                        pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(underlineArray[tempIndex][0] + underlineArray[tempIndex][2]), pp.service.convertToString(underlineArray[tempIndex][1] + underscorePosition));
                                    }
                                }
                                pp.service.pageStream.writeLine("Q");
                                pp.service.popColorFromStack();
                            }
                            // strikeout text
                            if ((mFont != null) && (mFont.font.strikeout)) {
                                pp.service.pageStream.writeLine("q");
                                pp.service.pushColorToStack();
                                var strikeoutSize = sizeInPt * 0.045;
                                var strikeoutPosition = sizeInPt * 0.25;
                                if (pp.service.pdfFont.StrikeoutSize != 0) {
                                    strikeoutSize = fontStrikeoutSize;
                                    strikeoutPosition = fontStrikeoutPosition;
                                }
                                if (strikeoutSize < 0.1)
                                    strikeoutSize = 0.1;
                                pp.service.pageStream.writeLine("{0} w", pp.service.convertToString(strikeoutSize));
                                if (textAngle != 0) {
                                    var AngleInRadians = textAngle * Math.PI / 180;
                                    pp.service.pageStream.writeLine("{0} {1} {2} {3} {4} {5} cm", pp.service.convertToString(Math.cos(AngleInRadians)), pp.service.convertToString(Math.sin(AngleInRadians)), pp.service.convertToString(-Math.sin(AngleInRadians)), pp.service.convertToString(Math.cos(AngleInRadians)), pp.service.convertToString(normTextX + normTextW / 2), pp.service.convertToString(normTextY + normTextH / 2));
                                }
                                if (mTextBrush != null) {
                                    // tempColor = StiBrush.ToColor(mTextBrush.TextBrush);
                                    pp.service.setStrokeColor(textColor);
                                }
                                for (var tempIndex = 0; tempIndex < stringList.length; tempIndex++) {
                                    if (underlineArray[tempIndex][2] != 0) {
                                        pp.service.pageStream.writeLine("{0} {1} m", pp.service.convertToString(underlineArray[tempIndex][0]), pp.service.convertToString(underlineArray[tempIndex][1] + strikeoutPosition));
                                        pp.service.pageStream.writeLine("{0} {1} l S", pp.service.convertToString(underlineArray[tempIndex][0] + underlineArray[tempIndex][2]), pp.service.convertToString(underlineArray[tempIndex][1] + strikeoutPosition));
                                    }
                                }
                                pp.service.pageStream.writeLine("Q");
                                pp.service.popColorFromStack();
                            }
                        }
                        // store annotation data
                        if (needAnnots) {
                            var seo = pp.service.annotsArray[pp.service.annotsCurrent];
                            seo.Multiline = wordWrap;
                            seo.X = pp.X;
                            seo.Y = pp.Y;
                            seo.Width = pp.Width;
                            seo.Height = pp.Height;
                            seo.Text = annotText;
                            seo.Component = pp.Component;
                            seo.Alignment = StiTextHorAlignment.Left;
                            if (mTextHorAlign != null) {
                                var horAlign = mTextHorAlign.horAlignment;
                                if (textOpt != null && textOpt.textOptions != null && textOpt.textOptions.rightToLeft) {
                                    if (horAlign == StiTextHorAlignment.Left)
                                        horAlign = StiTextHorAlignment.Right;
                                    else if (horAlign == StiTextHorAlignment.Right)
                                        horAlign = StiTextHorAlignment.Left;
                                }
                                seo.Alignment = horAlign;
                            }
                        }
                        //        #region Lines of underline
                        //        if (text.LinesOfUnderline != StiPenStyle.None) {
                        //            #region calculate coordinate
                        //            double coordTextY = pp.Y + marginB + correctY;
                        //            bool needLineUp = true;
                        //            bool needLineDown = true;
                        //            if (mVertAlign != null) {
                        //                if (linesCount == 0) linesCount = 1;
                        //                double textHeight = fontLineHeight * linesCount;
                        //                StiVertAlignment vertAlignment = mVertAlign.VertAlignment;
                        //                if ((textAngle != 0) && (textAngle != 90) && (textAngle != 180) && (textAngle != 270)) {
                        //                    vertAlignment = StiVertAlignment.Center;
                        //                }
                        //                if (vertAlignment == StiVertAlignment.Top) {
                        //                    coordTextY += textH - fontAscF;
                        //                    needLineUp = false;
                        //                }
                        //                if (vertAlignment == StiVertAlignment.Center) {
                        //                    coordTextY += (textH - textHeight) / 2 + (fontLineHeight - fontAscF);
                        //                }
                        //                if (vertAlignment == StiVertAlignment.Bottom) {
                        //                    coordTextY += (fontLineHeight - fontAscF);
                        //                    needLineDown = false;
                        //                }
                        //            }
                        //            coordTextY += fontDescF;
                        //            #endregion
                        //            #region style
                        //            bool needDouble = false;
                        //            double doubleLineOffset = 0;
                        //            IStiBorder mBorder = pp.Component as IStiBorder;
                        //            if (mBorder != null) {
                        //                Color tempColor2 = mBorder.border.Color;
                        //                SetStrokeColor(tempColor2);
                        //                double borderSizeHi = mBorder.border.Size;
                        //                if (text.LinesOfUnderline == StiPenStyle.Double) borderSizeHi = 1;
                        //                double borderSize = borderSizeHi * this.hiToTwips * 0.9;
                        //                pp.service.pageStream.writeLine("{0} w", pp.service.convertToString(borderSize));
                        //                needDouble = text.LinesOfUnderline == StiPenStyle.Double;
                        //                if (needDouble) {
                        //                    doubleLineOffset = borderSize;
                        //                }
                        //                #region set border style
                        //                double step = borderSize * 0.04;
                        //                switch (text.LinesOfUnderline) {
                        //                    case StiPenStyle.Dot:
                        //                        pp.service.pageStream.writeLine("[{0} {1}] 0 d", pp.service.convertToString(step), pp.service.convertToString(step * 55));
                        //                        break;
                        //                    case StiPenStyle.Dash:
                        //                        pp.service.pageStream.writeLine("[{0} {1}] 0 d", pp.service.convertToString(step * 50), pp.service.convertToString(step * 55));
                        //                        break;
                        //                    case StiPenStyle.DashDot:
                        //                        pp.service.pageStream.writeLine("[{0} {1} {2} {1}] 0 d", pp.service.convertToString(step * 50), pp.service.convertToString(step * 55), pp.service.convertToString(step));
                        //                        break;
                        //                    case StiPenStyle.DashDotDot:
                        //                        pp.service.pageStream.writeLine("[{0} {1} {2} {1} {2} {1}] 0 d", pp.service.convertToString(step * 50), pp.service.convertToString(step * 55), pp.service.convertToString(step));
                        //                        break;
                        //                }
                        //                #endregion
                        //            }
                        //            #endregion
                        //            #region draw lines
                        //            double lineY = coordTextY;
                        //            if (needLineUp) {
                        //                while (lineY + fontLineHeight < pp.Y + pp.Height - marginT) {
                        //                    lineY += fontLineHeight;
                        //                }
                        //            }
                        //            while (lineY > pp.Y + marginB + (needLineDown ? 0 : fontLineHeight)) {
                        //                pp.service.pageStream.writeLine("{0} {2} m {1} {2} l S",
                        //                    pp.service.convertToString(pp.X),
                        //                    pp.service.convertToString(pp.X + pp.Width),
                        //                    pp.service.convertToString(lineY + doubleLineOffset));
                        //                if (needDouble) {
                        //                    pp.service.pageStream.writeLine("{0} {2} m {1} {2} l S",
                        //                        pp.service.convertToString(pp.X),
                        //                        pp.service.convertToString(pp.X + pp.Width),
                        //                        pp.service.convertToString(lineY - doubleLineOffset));
                        //                }
                        //                lineY -= fontLineHeight;
                        //            }
                        //            #endregion
                        //        }
                        //        #endregion
                        if (!needAnnots) {
                            pp.service.pageStream.writeLine("Q");
                            pp.service.popColorFromStack();
                        }
                    }
                };
                StiPdfRenderText.isWordWrapSymbol = function (sb, index) {
                    var sym1 = sb.charCodeAt(index);
                    var st1 = sb.charAt(index);
                    if (((sym1 >= 0x3000) && (sym1 <= 0xd7af)) || // East Asian & Unified CJK
                        (Char.isWhitespace(sb, index) && (sym1 != 0xa0)) ||
                        st1 == "(" || st1 == "{")
                        return true;
                    if (index > 0) {
                        var sym2 = sb.charAt(index - 1);
                        if (sym2 == "!" || sym2 == "%" || sym2 == ")" || sym2 == "}" || sym2 == "-" || sym2 == "?")
                            return true;
                    }
                    return false;
                };
                StiPdfRenderText.getTabsSize = function (textOp, sizeInPt, currentPosition) {
                    if ((textOp != null) && (textOp.textOptions != null)) {
                        var position = currentPosition;
                        var spaceWidth = 750 / sizeInPt; // empiric; for CourierNew must be 726 ?
                        var otherTab = spaceWidth * textOp.textOptions.distanceBetweenTabs;
                        var firstTab = spaceWidth * textOp.textOptions.firstTabOffset + otherTab;
                        if (currentPosition < firstTab) {
                            position = firstTab;
                        }
                        else {
                            if (textOp.textOptions.distanceBetweenTabs > 0) {
                                var kolTabs = Math.trunc((currentPosition - firstTab) / otherTab);
                                kolTabs++;
                                position = firstTab + kolTabs * otherTab;
                            }
                        }
                        return (position - currentPosition);
                    }
                    else {
                        return 0;
                    }
                };
                StiPdfRenderText.renderTextFont = function (pp) {
                    var mFont = pp.Component.sti.as(IStiFont);
                    if (mFont != null) {
                        var fnt = pp.service.pdfFont.getFontNumber(mFont.font);
                        var fntSize = mFont.font.sizeInPoints * this.fontCorrectValue;
                        pp.service.pageStream.writeLine("/F{0} {1} Tf", fnt, pp.service.convertToString(fntSize, this.precision_digits_font));
                        pp.service.pdfFont.currentFont = fnt;
                        if (pp.service.haveAnnots && (pp.Component.sti.as(StiText)).editable) {
                            var seo = pp.service.annotsArray[pp.service.annotsCurrent];
                            seo.FontNumber = fnt;
                            seo.FontSize = fntSize;
                        }
                    }
                };
                StiPdfRenderText.hiToTwips = 0.72; // convert from hi(hundredths of inch) to points
                StiPdfRenderText.precision_digits_font = 3;
                StiPdfRenderText.fontCorrectValue = 0.955;
                StiPdfRenderText.boldFontStrokeWidthValue = 0.031;
                StiPdfRenderText.italicAngleTanValue = 0.325; // 18 degrees
                return StiPdfRenderText;
            }());
            Export.StiPdfRenderText = StiPdfRenderText;
        })(Export = Report.Export || (Report.Export = {}));
    })(Report = Stimulsoft.Report || (Stimulsoft.Report = {}));
})(Stimulsoft || (Stimulsoft = {}));
var Stimulsoft;
(function (Stimulsoft) {
    var Report;
    (function (Report) {
        var Export;
        (function (Export) {
            var StiPdfResources = /** @class */ (function () {
                function StiPdfResources() {
                }
                Object.defineProperty(StiPdfResources, "standardFontCharsNames", {
                    get: function () {
                        if (this._standardFontCharsNames == null) {
                            var charsNames = [
                                "0020space",
                                "0021exclam",
                                "0022quotedbl",
                                "0023numbersign",
                                "0024dollar",
                                "0025percent",
                                "0026ampersand",
                                "0027quotesingle",
                                "0028parenleft",
                                "0029parenright",
                                "002Aasterisk",
                                "002Bplus",
                                "002Ccomma",
                                "002Dhyphen",
                                "002Eperiod",
                                "002Fslash",
                                "0030zero",
                                "0031one",
                                "0032two",
                                "0033three",
                                "0034four",
                                "0035five",
                                "0036six",
                                "0037seven",
                                "0038eight",
                                "0039nine",
                                "003Acolon",
                                "003Bsemicolon",
                                "003Cless",
                                "003Dequal",
                                "003Egreater",
                                "003Fquestion",
                                "0040at",
                                "0041A",
                                "0042B",
                                "0043C",
                                "0044D",
                                "0045E",
                                "0046F",
                                "0047G",
                                "0048H",
                                "0049I",
                                "004AJ",
                                "004BK",
                                "004CL",
                                "004DM",
                                "004EN",
                                "004FO",
                                "0050P",
                                "0051Q",
                                "0052R",
                                "0053S",
                                "0054T",
                                "0055U",
                                "0056V",
                                "0057W",
                                "0058X",
                                "0059Y",
                                "005AZ",
                                "005Bbracketleft",
                                "005Cbackslash",
                                "005Dbracketright",
                                "005Easciicircum",
                                "005Funderscore",
                                "0060grave",
                                "0061a",
                                "0062b",
                                "0063c",
                                "0064d",
                                "0065e",
                                "0066f",
                                "0067g",
                                "0068h",
                                "0069i",
                                "006Aj",
                                "006Bk",
                                "006Cl",
                                "006Dm",
                                "006En",
                                "006Fo",
                                "0070p",
                                "0071q",
                                "0072r",
                                "0073s",
                                "0074t",
                                "0075u",
                                "0076v",
                                "0077w",
                                "0078x",
                                "0079y",
                                "007Az",
                                "007Bbraceleft",
                                "007Cbar",
                                "007Dbraceright",
                                "007Easciitilde",
                                "007FcontrolDEL",
                                "00A0nbspace",
                                "00A1exclamdown",
                                "00A2cent",
                                "00A3sterling",
                                "00A4currency",
                                "00A5yen",
                                "00A6brokenbar",
                                "00A7section",
                                "00A8dieresis",
                                "00A9copyright",
                                "00AAordfeminine",
                                "00ABguillemotleft",
                                "00AClogicalnot",
                                "00ADsofthyphen",
                                "00AEregistered",
                                "00AFmacron",
                                "00B0degree",
                                "00B1plusminus",
                                "00B2twosuperior",
                                "00B3threesuperior",
                                "00B4acute",
                                "00B5mu",
                                "00B6paragraph",
                                "00B7periodcentered",
                                "00B8cedilla",
                                "00B9onesuperior",
                                "00BAordmasculine",
                                "00BBguillemotright",
                                "00BConequarter",
                                "00BDonehalf",
                                "00BEthreequarters",
                                "00BFquestiondown",
                                "00C0Agrave",
                                "00C1Aacute",
                                "00C2Acircumflex",
                                "00C3Atilde",
                                "00C4Adieresis",
                                "00C5Aring",
                                "00C6AE",
                                "00C7Ccedilla",
                                "00C8Egrave",
                                "00C9Eacute",
                                "00CAEcircumflex",
                                "00CBEdieresis",
                                "00CCIgrave",
                                "00CDIacute",
                                "00CEIcircumflex",
                                "00CFIdieresis",
                                "00D0Eth",
                                "00D1Ntilde",
                                "00D2Ograve",
                                "00D3Oacute",
                                "00D4Ocircumflex",
                                "00D5Otilde",
                                "00D6Odieresis",
                                "00D7multiply",
                                "00D8Oslash",
                                "00D9Ugrave",
                                "00DAUacute",
                                "00DBUcircumflex",
                                "00DCUdieresis",
                                "00DDYacute",
                                "00DEThorn",
                                "00DFgermandbls",
                                "00E0agrave",
                                "00E1aacute",
                                "00E2acircumflex",
                                "00E3atilde",
                                "00E4adieresis",
                                "00E5aring",
                                "00E6ae",
                                "00E7ccedilla",
                                "00E8egrave",
                                "00E9eacute",
                                "00EAecircumflex",
                                "00EBedieresis",
                                "00ECigrave",
                                "00EDiacute",
                                "00EEicircumflex",
                                "00EFidieresis",
                                "00F0eth",
                                "00F1ntilde",
                                "00F2ograve",
                                "00F3oacute",
                                "00F4ocircumflex",
                                "00F5otilde",
                                "00F6odieresis",
                                "00F7divide",
                                "00F8oslash",
                                "00F9ugrave",
                                "00FAuacute",
                                "00FBucircumflex",
                                "00FCudieresis",
                                "00FDyacute",
                                "00FEthorn",
                                "00FFydieresis",
                                "0100Amacron",
                                "0101amacron",
                                "0102Abreve",
                                "0103abreve",
                                "0104Aogonek",
                                "0105aogonek",
                                "0106Cacute",
                                "0107cacute",
                                "0108Ccircumflex",
                                "0109ccircumflex",
                                "010ACdotaccent",
                                "010Bcdotaccent",
                                "010CCcaron",
                                "010Dccaron",
                                "010EDcaron",
                                "010Fdcaron",
                                "0110Dcroat",
                                "0111dcroat",
                                "0112Emacron",
                                "0113emacron",
                                "0114Ebreve",
                                "0115ebreve",
                                "0116Edotaccent",
                                "0117edotaccent",
                                "0118Eogonek",
                                "0119eogonek",
                                "011AEcaron",
                                "011Becaron",
                                "011CGcircumflex",
                                "011Dgcircumflex",
                                "011EGbreve",
                                "011Fgbreve",
                                "0120Gdotaccent",
                                "0121gdotaccent",
                                "0122Gcommaaccent",
                                "0123gcommaaccent",
                                "0124Hcircumflex",
                                "0125hcircumflex",
                                "0126Hbar",
                                "0127hbar",
                                "0128Itilde",
                                "0129itilde",
                                "012AImacron",
                                "012Bimacron",
                                "012CIbreve",
                                "012Dibreve",
                                "012EIogonek",
                                "012Fiogonek",
                                "0130Idotaccent",
                                "0131dotlessi",
                                "0132IJ",
                                "0133ij",
                                "0134Jcircumflex",
                                "0135jcircumflex",
                                "0136Kcommaaccent",
                                "0137kcommaaccent",
                                "0138kgreenlandic",
                                "0139Lacute",
                                "013Alacute",
                                "013BLcommaaccent",
                                "013Clcommaaccent",
                                "013DLcaron",
                                "013Elcaron",
                                "013FLdot",
                                "0140ldot",
                                "0141Lslash",
                                "0142lslash",
                                "0143Nacute",
                                "0144nacute",
                                "0145Ncommaaccent",
                                "0146ncommaaccent",
                                "0147Ncaron",
                                "0148ncaron",
                                "0149napostrophe",
                                "014AEng",
                                "014Beng",
                                "014COmacron",
                                "014Domacron",
                                "014EObreve",
                                "014Fobreve",
                                "0150Ohungarumlaut",
                                "0151ohungarumlaut",
                                "0152OE",
                                "0153oe",
                                "0154Racute",
                                "0155racute",
                                "0156Rcommaaccent",
                                "0157rcommaaccent",
                                "0158Rcaron",
                                "0159rcaron",
                                "015ASacute",
                                "015Bsacute",
                                "015CScircumflex",
                                "015Dscircumflex",
                                "015EScedilla",
                                "015Fscedilla",
                                "0160Scaron",
                                "0161scaron",
                                "0162Tcommaaccent",
                                "0163tcommaaccent",
                                "0164Tcaron",
                                "0165tcaron",
                                "0166Tbar",
                                "0167tbar",
                                "0168Utilde",
                                "0169utilde",
                                "016AUmacron",
                                "016Bumacron",
                                "016CUbreve",
                                "016Dubreve",
                                "016EUring",
                                "016Furing",
                                "0170Uhungarumlaut",
                                "0171uhungarumlaut",
                                "0172Uogonek",
                                "0173uogonek",
                                "0174Wcircumflex",
                                "0175wcircumflex",
                                "0176Ycircumflex",
                                "0177ycircumflex",
                                "0178Ydieresis",
                                "0179Zacute",
                                "017Azacute",
                                "017BZdotaccent",
                                "017Czdotaccent",
                                "017DZcaron",
                                "017Ezcaron",
                                "017Flongs",
                                "0180bstroke",
                                "0181Bhook",
                                "0182Btopbar",
                                "0183btopbar",
                                "0184Tonesix",
                                "0185tonesix",
                                "0186Oopen",
                                "0187Chook",
                                "0188chook",
                                "0189Dafrican",
                                "018ADhook",
                                "018BDtopbar",
                                "018Cdtopbar",
                                "018Ddeltaturned",
                                "018EEreversed",
                                "018FSchwa",
                                "0190Eopen",
                                "0191Fhook",
                                "0192florin",
                                "0193Ghook",
                                "0194Gammaafrican",
                                "0195hv",
                                "0196Iotaafrican",
                                "0197Istroke",
                                "0198Khook",
                                "0199khook",
                                "019Albar",
                                "019Blambdastroke",
                                "019CMturned",
                                "019DNhookleft",
                                "019Enlegrightlong",
                                "019FOcenteredtilde",
                                "01A0Ohorn",
                                "01A1ohorn",
                                "01A2Oi",
                                "01A3oi",
                                "01A4Phook",
                                "01A5phook",
                                "01A6yr",
                                "01A7Tonetwo",
                                "01A8tonetwo",
                                "01A9Esh",
                                "01AAeshreversedloop",
                                "01ABtpalatalhook",
                                "01ACThook",
                                "01ADthook",
                                "01AETretroflexhook",
                                "01AFUhorn",
                                "01B0uhorn",
                                "01B1Upsilonafrican",
                                "01B2Vhook",
                                "01B3Yhook",
                                "01B4yhook",
                                "01B5Zstroke",
                                "01B6zstroke",
                                "01B7Ezh",
                                "01B8Ezhreversed",
                                "01B9ezhreversed",
                                "01BAezhtail",
                                "01BBtwostroke",
                                "01BCTonefive",
                                "01BDtonefive",
                                "01BEglottalinvertedstroke",
                                "01BFwynn",
                                "01C0clickdental",
                                "01C1clicklateral",
                                "01C2clickalveolar",
                                "01C3clickretroflex",
                                "01C4DZcaron",
                                "01C5Dzcaron",
                                "01C6dzcaron",
                                "01C7LJ",
                                "01C8Lj",
                                "01C9lj",
                                "01CANJ",
                                "01CBNj",
                                "01CCnj",
                                "01CDAcaron",
                                "01CEacaron",
                                "01CFIcaron",
                                "01D0icaron",
                                "01D1Ocaron",
                                "01D2ocaron",
                                "01D3Ucaron",
                                "01D4ucaron",
                                "01F0jcaron",
                                "01F1DZ",
                                "01F2Dz",
                                "01F3dz",
                                "01F4Gacute",
                                "01F5gacute",
                                "01FAAringacute",
                                "01FBaringacute",
                                "01FCAEacute",
                                "01FDaeacute",
                                "01FEOslashacute",
                                "01FFoslashacute",
                                "0254oopen",
                                "0255ccurl",
                                "0256dtail",
                                "0257dhook",
                                "0258ereversed",
                                "0259schwa",
                                "025Aschwahook",
                                "025Beopen",
                                "025Fjdotlessstroke",
                                "0260ghook",
                                "0261gscript",
                                "0264ramshorn",
                                "0265hturned",
                                "0266hhook",
                                "0267henghook",
                                "0268istroke",
                                "0269iotalatin",
                                "026Clbelt",
                                "026Elezh",
                                "026Fmturned",
                                "0271mhook",
                                "0272nhookleft",
                                "0275obarred",
                                "0278philatin",
                                "0279rturned",
                                "027Brhookturned",
                                "027Crlongleg",
                                "027Drhook",
                                "027Erfishhook",
                                "0282shook",
                                "0283esh",
                                "0286eshcurl",
                                "0287tturned",
                                "0289ubar",
                                "028Bvhook",
                                "028Cvturned",
                                "028Dwturned",
                                "028Eyturned",
                                "0290zretroflexhook",
                                "0291zcurl",
                                "0292ezh",
                                "0293ezhcurl",
                                "0294glottalstop",
                                "02A3dzaltone",
                                "02A4dezh",
                                "02A5dzcurl",
                                "02A6ts",
                                "02A7tesh",
                                "02A8tccurl",
                                "02D6plusmod",
                                "02D7minusmod",
                                "02D8breve",
                                "02D9dotaccent",
                                "02DAring",
                                "02DBogonek",
                                "02DCtilde",
                                "0391Alpha",
                                "0392Beta",
                                "0393Gamma",
                                "0394Deltagreek",
                                "0395Epsilon",
                                "0396Zeta",
                                "0397Eta",
                                "0398Theta",
                                "0399Iota",
                                "039AKappa",
                                "039BLambda",
                                "039CMu",
                                "039DNu",
                                "039EXi",
                                "039FOmicron",
                                "03A0Pi",
                                "03A1Rho",
                                "03A3Sigma",
                                "03A4Tau",
                                "03A5Upsilon",
                                "03A6Phi",
                                "03A7Chi",
                                "03A8Psi",
                                "03A9Omegagreek",
                                "03AAIotadieresis",
                                "03ABUpsilondieresis",
                                "03ACalphatonos",
                                "03ADepsilontonos",
                                "03AEetatonos",
                                "03AFiotatonos",
                                "03B0upsilondieresistonos",
                                "03B1alpha",
                                "03B2beta",
                                "03B3gamma",
                                "03B4delta",
                                "03B5epsilon",
                                "03B6zeta",
                                "03B7eta",
                                "03B8theta",
                                "03B9iota",
                                "03BAkappa",
                                "03BBlambda",
                                "03BCmu",
                                "03BDnu",
                                "03BExi",
                                "03BFomicron",
                                "03C0pi",
                                "03C1rho",
                                "03C2sigma1",
                                "03C3sigma",
                                "03C4tau",
                                "03C5upsilon",
                                "03C6phi",
                                "03C7chi",
                                "03C8psi",
                                "03C9omega",
                                "03CAiotadieresis",
                                "03CBupsilondieresis",
                                "03CComicrontonos",
                                "03CDupsilontonos",
                                "03CEomegatonos",
                                "03D0betasymbolgreek",
                                "03D1theta1",
                                "03D2Upsilon1",
                                "03D5phi1",
                                "03D6omega1",
                                "03DAStigmagreek",
                                "03DCDigammagreek",
                                "03DEKoppagreek",
                                "03E0Sampigreek",
                                "03E2Sheicoptic",
                                "03E3sheicoptic",
                                "03E4Feicoptic",
                                "03E5feicoptic",
                                "03E6Kheicoptic",
                                "03E7kheicoptic",
                                "03E8Horicoptic",
                                "03E9horicoptic",
                                "03EAGangiacoptic",
                                "03EBgangiacoptic",
                                "03ECShimacoptic",
                                "03EDshimacoptic",
                                "03EEDeicoptic",
                                "03EFdeicoptic",
                                "03F0kappasymbolgreek",
                                "03F1rhosymbolgreek",
                                "03F3yotgreek",
                                "0401afii10023",
                                "0402afii10051",
                                "0403afii10052",
                                "0404afii10053",
                                "0405afii10054",
                                "0406afii10055",
                                "0407afii10056",
                                "0408afii10057",
                                "0409afii10058",
                                "040Aafii10059",
                                "040Bafii10060",
                                "040Cafii10061",
                                "040Eafii10062",
                                "040Fafii10145",
                                "0410afii10017",
                                "0411afii10018",
                                "0412afii10019",
                                "0413afii10020",
                                "0414afii10021",
                                "0415afii10022",
                                "0416afii10024",
                                "0417afii10025",
                                "0418afii10026",
                                "0419afii10027",
                                "041Aafii10028",
                                "041Bafii10029",
                                "041Cafii10030",
                                "041Dafii10031",
                                "041Eafii10032",
                                "041Fafii10033",
                                "0420afii10034",
                                "0421afii10035",
                                "0422afii10036",
                                "0423afii10037",
                                "0424afii10038",
                                "0425afii10039",
                                "0426afii10040",
                                "0427afii10041",
                                "0428afii10042",
                                "0429afii10043",
                                "042Aafii10044",
                                "042Bafii10045",
                                "042Cafii10046",
                                "042Dafii10047",
                                "042Eafii10048",
                                "042Fafii10049",
                                "0430afii10065",
                                "0431afii10066",
                                "0432afii10067",
                                "0433afii10068",
                                "0434afii10069",
                                "0435afii10070",
                                "0436afii10072",
                                "0437afii10073",
                                "0438afii10074",
                                "0439afii10075",
                                "043Aafii10076",
                                "043Bafii10077",
                                "043Cafii10078",
                                "043Dafii10079",
                                "043Eafii10080",
                                "043Fafii10081",
                                "0440afii10082",
                                "0441afii10083",
                                "0442afii10084",
                                "0443afii10085",
                                "0444afii10086",
                                "0445afii10087",
                                "0446afii10088",
                                "0447afii10089",
                                "0448afii10090",
                                "0449afii10091",
                                "044Aafii10092",
                                "044Bafii10093",
                                "044Cafii10094",
                                "044Dafii10095",
                                "044Eafii10096",
                                "044Fafii10097",
                                "0451afii10071",
                                "0452afii10099",
                                "0453afii10100",
                                "0454afii10101",
                                "0455afii10102",
                                "0456afii10103",
                                "0457afii10104",
                                "0458afii10105",
                                "0459afii10106",
                                "045Aafii10107",
                                "045Bafii10108",
                                "045Cafii10109",
                                "045Eafii10110",
                                "045Fafii10193",
                                "0462afii10146",
                                "0463afii10194",
                                "0472afii10147",
                                "0473afii10195",
                                "0474afii10148",
                                "0475afii10196",
                                "0490afii10050",
                                "0491afii10098",
                                "04D9afii10846",
                                "060Cafii57388",
                                "061Bafii57403",
                                "061Fafii57407",
                                "0621afii57409",
                                "0622afii57410",
                                "0623afii57411",
                                "0624afii57412",
                                "0625afii57413",
                                "0626afii57414",
                                "0627afii57415",
                                "0628afii57416",
                                "0629afii57417",
                                "062Aafii57418",
                                "062Bafii57419",
                                "062Cafii57420",
                                "062Dafii57421",
                                "062Eafii57422",
                                "062Fafii57423",
                                "0630afii57424",
                                "0631afii57425",
                                "0632afii57426",
                                "0633afii57427",
                                "0634afii57428",
                                "0635afii57429",
                                "0636afii57430",
                                "0637afii57431",
                                "0638afii57432",
                                "0639afii57433",
                                "063Aafii57434",
                                "0640afii57440",
                                "0641afii57441",
                                "0642afii57442",
                                "0643afii57443",
                                "0644afii57444",
                                "0645afii57445",
                                "0646afii57446",
                                "0647afii57470",
                                "0648afii57448",
                                "0649afii57449",
                                "064Aafii57450",
                                "064Bafii57451",
                                "064Cafii57452",
                                "064Dafii57453",
                                "064Eafii57454",
                                "064Fafii57455",
                                "0650afii57456",
                                "0651afii57457",
                                "0652afii57458",
                                "0660afii57392",
                                "0661afii57393",
                                "0662afii57394",
                                "0663afii57395",
                                "0664afii57396",
                                "0665afii57397",
                                "0666afii57398",
                                "0667afii57399",
                                "0668afii57400",
                                "0669afii57401",
                                "066Aafii57381",
                                "066Bdecimalseparatorarabic",
                                "066Cthousandsseparatorarabic",
                                "066Dafii63167",
                                "0679afii57511",
                                "067Eafii57506",
                                "0686afii57507",
                                "0688afii57512",
                                "0691afii57513",
                                "0698afii57508",
                                "06A4afii57505",
                                "06AFafii57509",
                                "06BAafii57514",
                                "06C1hehaltonearabic",
                                "06D1yehthreedotsbelowarabic",
                                "06D2afii57519",
                                "06D5afii57534",
                                "06F0zeropersian",
                                "06F1onepersian",
                                "06F2twopersian",
                                "06F3threepersian",
                                "06F4fourpersian",
                                "06F5fivepersian",
                                "06F6sixpersian",
                                "06F7sevenpersian",
                                "06F8eightpersian",
                                "06F9ninepersian",
                                "1E00Aringbelow",
                                "1E01aringbelow",
                                "1E02Bdotaccent",
                                "1E03bdotaccent",
                                "1E04Bdotbelow",
                                "1E05bdotbelow",
                                "1E06Blinebelow",
                                "1E07blinebelow",
                                "1E08Ccedillaacute",
                                "1E09ccedillaacute",
                                "1E0ADdotaccent",
                                "1E0Bddotaccent",
                                "1E0CDdotbelow",
                                "1E0Dddotbelow",
                                "1E0EDlinebelow",
                                "1E0Fdlinebelow",
                                "1E10Dcedilla",
                                "1E11dcedilla",
                                "1E12Dcircumflexbelow",
                                "1E13dcircumflexbelow",
                                "1E14Emacrongrave",
                                "1E15emacrongrave",
                                "1E16Emacronacute",
                                "1E17emacronacute",
                                "1E18Ecircumflexbelow",
                                "1E19ecircumflexbelow",
                                "1E1AEtildebelow",
                                "1E1Betildebelow",
                                "1E1CEcedillabreve",
                                "1E1Decedillabreve",
                                "1E1EFdotaccent",
                                "1E1Ffdotaccent",
                                "1E20Gmacron",
                                "1E21gmacron",
                                "1E22Hdotaccent",
                                "1E23hdotaccent",
                                "1E24Hdotbelow",
                                "1E25hdotbelow",
                                "1E26Hdieresis",
                                "1E27hdieresis",
                                "1E28Hcedilla",
                                "1E29hcedilla",
                                "1E2AHbrevebelow",
                                "1E2Bhbrevebelow",
                                "1E2CItildebelow",
                                "1E2Ditildebelow",
                                "1E2EIdieresisacute",
                                "1E2Fidieresisacute",
                                "1E30Kacute",
                                "1E31kacute",
                                "1E32Kdotbelow",
                                "1E33kdotbelow",
                                "1E34Klinebelow",
                                "1E35klinebelow",
                                "1E36Ldotbelow",
                                "1E37ldotbelow",
                                "1E38Ldotbelowmacron",
                                "1E39ldotbelowmacron",
                                "1E3ALlinebelow",
                                "1E3Bllinebelow",
                                "1E3CLcircumflexbelow",
                                "1E3Dlcircumflexbelow",
                                "1E3EMacute",
                                "1E3Fmacute",
                                "1E40Mdotaccent",
                                "1E41mdotaccent",
                                "1E42Mdotbelow",
                                "1E43mdotbelow",
                                "1E44Ndotaccent",
                                "1E45ndotaccent",
                                "1E46Ndotbelow",
                                "1E47ndotbelow",
                                "1E48Nlinebelow",
                                "1E49nlinebelow",
                                "1E4ANcircumflexbelow",
                                "1E4Bncircumflexbelow",
                                "1E4COtildeacute",
                                "1E4Dotildeacute",
                                "1E4EOtildedieresis",
                                "1E4Fotildedieresis",
                                "1E50Omacrongrave",
                                "1E51omacrongrave",
                                "1E52Omacronacute",
                                "1E53omacronacute",
                                "1E54Pacute",
                                "1E55pacute",
                                "1E56Pdotaccent",
                                "1E57pdotaccent",
                                "1E58Rdotaccent",
                                "1E59rdotaccent",
                                "1E5ARdotbelow",
                                "1E5Brdotbelow",
                                "1E5CRdotbelowmacron",
                                "1E5Drdotbelowmacron",
                                "1E5ERlinebelow",
                                "1E5Frlinebelow",
                                "1E60Sdotaccent",
                                "1E61sdotaccent",
                                "1E62Sdotbelow",
                                "1E63sdotbelow",
                                "1E64Sacutedotaccent",
                                "1E65sacutedotaccent",
                                "1E66Scarondotaccent",
                                "1E67scarondotaccent",
                                "1E68Sdotbelowdotaccent",
                                "1E69sdotbelowdotaccent",
                                "1E6ATdotaccent",
                                "1E6Btdotaccent",
                                "1E6CTdotbelow",
                                "1E6Dtdotbelow",
                                "1E6ETlinebelow",
                                "1E6Ftlinebelow",
                                "1E70Tcircumflexbelow",
                                "1E71tcircumflexbelow",
                                "1E72Udieresisbelow",
                                "1E73udieresisbelow",
                                "1E74Utildebelow",
                                "1E75utildebelow",
                                "1E76Ucircumflexbelow",
                                "1E77ucircumflexbelow",
                                "1E78Utildeacute",
                                "1E79utildeacute",
                                "1E7AUmacrondieresis",
                                "1E7Bumacrondieresis",
                                "1E7CVtilde",
                                "1E7Dvtilde",
                                "1E7EVdotbelow",
                                "1E7Fvdotbelow",
                                "1E80Wgrave",
                                "1E81wgrave",
                                "1E82Wacute",
                                "1E83wacute",
                                "1E84Wdieresis",
                                "1E85wdieresis",
                                "1E86Wdotaccent",
                                "1E87wdotaccent",
                                "1E88Wdotbelow",
                                "1E89wdotbelow",
                                "1E8AXdotaccent",
                                "1E8Bxdotaccent",
                                "1E8CXdieresis",
                                "1E8Dxdieresis",
                                "1E8EYdotaccent",
                                "1E8Fydotaccent",
                                "1E90Zcircumflex",
                                "1E91zcircumflex",
                                "1E92Zdotbelow",
                                "1E93zdotbelow",
                                "1E94Zlinebelow",
                                "1E95zlinebelow",
                                "1E96hlinebelow",
                                "1E97tdieresis",
                                "1E98wring",
                                "1E99yring",
                                "1E9Aarighthalfring",
                                "1E9Bslongdotaccent",
                                "1EA0Adotbelow",
                                "1EA1adotbelow",
                                "1EA2Ahookabove",
                                "1EA3ahookabove",
                                "1EA4Acircumflexacute",
                                "1EA5acircumflexacute",
                                "1EA6Acircumflexgrave",
                                "1EA7acircumflexgrave",
                                "1EA8Acircumflexhookabove",
                                "1EA9acircumflexhookabove",
                                "1EAAAcircumflextilde",
                                "1EABacircumflextilde",
                                "1EACAcircumflexdotbelow",
                                "1EADacircumflexdotbelow",
                                "1EAEAbreveacute",
                                "1EAFabreveacute",
                                "1EB0Abrevegrave",
                                "1EB1abrevegrave",
                                "1EB2Abrevehookabove",
                                "1EB3abrevehookabove",
                                "1EB4Abrevetilde",
                                "1EB5abrevetilde",
                                "1EB6Abrevedotbelow",
                                "1EB7abrevedotbelow",
                                "1EB8Edotbelow",
                                "1EB9edotbelow",
                                "1EBAEhookabove",
                                "1EBBehookabove",
                                "1EBCEtilde",
                                "1EBDetilde",
                                "1EBEEcircumflexacute",
                                "1EBFecircumflexacute",
                                "1EC0Ecircumflexgrave",
                                "1EC1ecircumflexgrave",
                                "1EC2Ecircumflexhookabove",
                                "1EC3ecircumflexhookabove",
                                "1EC4Ecircumflextilde",
                                "1EC5ecircumflextilde",
                                "1EC6Ecircumflexdotbelow",
                                "1EC7ecircumflexdotbelow",
                                "1EC8Ihookabove",
                                "1EC9ihookabove",
                                "1ECAIdotbelow",
                                "1ECBidotbelow",
                                "1ECCOdotbelow",
                                "1ECDodotbelow",
                                "1ECEOhookabove",
                                "1ECFohookabove",
                                "1ED0Ocircumflexacute",
                                "1ED1ocircumflexacute",
                                "1ED2Ocircumflexgrave",
                                "1ED3ocircumflexgrave",
                                "1ED4Ocircumflexhookabove",
                                "1ED5ocircumflexhookabove",
                                "1ED6Ocircumflextilde",
                                "1ED7ocircumflextilde",
                                "1ED8Ocircumflexdotbelow",
                                "1ED9ocircumflexdotbelow",
                                "1EDAOhornacute",
                                "1EDBohornacute",
                                "1EDCOhorngrave",
                                "1EDDohorngrave",
                                "1EDEOhornhookabove",
                                "1EDFohornhookabove",
                                "1EE0Ohorntilde",
                                "1EE1ohorntilde",
                                "1EE2Ohorndotbelow",
                                "1EE3ohorndotbelow",
                                "1EE4Udotbelow",
                                "1EE5udotbelow",
                                "1EE6Uhookabove",
                                "1EE7uhookabove",
                                "1EE8Uhornacute",
                                "1EE9uhornacute",
                                "1EEAUhorngrave",
                                "1EEBuhorngrave",
                                "1EECUhornhookabove",
                                "1EEDuhornhookabove",
                                "1EEEUhorntilde",
                                "1EEFuhorntilde",
                                "1EF0Uhorndotbelow",
                                "1EF1uhorndotbelow",
                                "1EF2Ygrave",
                                "1EF3ygrave",
                                "1EF4Ydotbelow",
                                "1EF5ydotbelow",
                                "1EF6Yhookabove",
                                "1EF7yhookabove",
                                "1EF8Ytilde",
                                "1EF9ytilde",
                                "2002enspace",
                                "200Bzerowidthspace",
                                "200Cafii61664",
                                "200Dafii301",
                                "200Eafii299",
                                "200Fafii300",
                                "2010hyphentwo",
                                "2012figuredash",
                                "2013endash",
                                "2014emdash",
                                "2015afii00208",
                                "2016dblverticalbar",
                                "2017underscoredbl",
                                "2018quoteleft",
                                "2019quoteright",
                                "201Aquotesinglbase",
                                "201Bquotereversed",
                                "201Cquotedblleft",
                                "201Dquotedblright",
                                "201Equotedblbase",
                                "2020dagger",
                                "2021daggerdbl",
                                "2022bullet",
                                "2024onedotenleader",
                                "2025twodotenleader",
                                "2026ellipsis",
                                "202Cafii61573",
                                "202Dafii61574",
                                "202Eafii61575",
                                "2030perthousand",
                                "2032minute",
                                "2033second",
                                "2035primereversed",
                                "2039guilsinglleft",
                                "203Aguilsinglright",
                                "203Breferencemark",
                                "203Cexclamdbl",
                                "203Eoverline",
                                "2042asterism",
                                "2044fraction",
                                "2070zerosuperior",
                                "2074foursuperior",
                                "2075fivesuperior",
                                "2076sixsuperior",
                                "2077sevensuperior",
                                "2078eightsuperior",
                                "2079ninesuperior",
                                "207Aplussuperior",
                                "207Cequalsuperior",
                                "207Dparenleftsuperior",
                                "207Eparenrightsuperior",
                                "207Fnsuperior",
                                "2080zeroinferior",
                                "2081oneinferior",
                                "2082twoinferior",
                                "2083threeinferior",
                                "2084fourinferior",
                                "2085fiveinferior",
                                "2086sixinferior",
                                "2087seveninferior",
                                "2088eightinferior",
                                "2089nineinferior",
                                "208Dparenleftinferior",
                                "208Eparenrightinferior",
                                "20A1colonmonetary",
                                "20A2cruzeiro",
                                "20A3franc",
                                "20A4afii08941",
                                "20A7peseta",
                                "20A9won",
                                "20AAafii57636",
                                "20ABdong",
                                "20ACEuro",
                                "2103centigrade",
                                "2105afii61248",
                                "2109fahrenheit",
                                "2111Ifraktur",
                                "2113afii61289",
                                "2116afii61352",
                                "2118weierstrass",
                                "211CRfraktur",
                                "211Eprescription",
                                "2121telephone",
                                "2122trademark",
                                "2126Omega",
                                "212Bangstrom",
                                "212Eestimated",
                                "2135aleph",
                                "2153onethird",
                                "2154twothirds",
                                "215Boneeighth",
                                "215Cthreeeighths",
                                "215Dfiveeighths",
                                "215Eseveneighths",
                                "2160Oneroman",
                                "2161Tworoman",
                                "2162Threeroman",
                                "2163Fourroman",
                                "2164Fiveroman",
                                "2165Sixroman",
                                "2166Sevenroman",
                                "2167Eightroman",
                                "2168Nineroman",
                                "2169Tenroman",
                                "216AElevenroman",
                                "216BTwelveroman",
                                "2170oneroman",
                                "2171tworoman",
                                "2172threeroman",
                                "2173fourroman",
                                "2174fiveroman",
                                "2175sixroman",
                                "2176sevenroman",
                                "2177eightroman",
                                "2178nineroman",
                                "2179tenroman",
                                "217Aelevenroman",
                                "217Btwelveroman",
                                "2200universal",
                                "2202partialdiff",
                                "2203existential",
                                "2205emptyset",
                                "2206Delta",
                                "2207gradient",
                                "2208element",
                                "2209notelement",
                                "220Bsuchthat",
                                "220Cnotcontains",
                                "220Fproduct",
                                "2211summation",
                                "2212minus",
                                "2213minusplus",
                                "2215divisionslash",
                                "2217asteriskmath",
                                "2219bulletoperator",
                                "221Aradical",
                                "221Dproportional",
                                "221Einfinity",
                                "221Forthogonal",
                                "2220angle",
                                "2223divides",
                                "2225parallel",
                                "2226notparallel",
                                "2227logicaland",
                                "2228logicalor",
                                "2229intersection",
                                "222Aunion",
                                "222Bintegral",
                                "222Cdblintegral",
                                "222Econtourintegral",
                                "2234therefore",
                                "2235because",
                                "2236ratio",
                                "2237proportion",
                                "223Csimilar",
                                "223Dreversedtilde",
                                "2243asymptoticallyequal",
                                "2245congruent",
                                "2248approxequal",
                                "224Callequal",
                                "2250approaches",
                                "2251geometricallyequal",
                                "2252approxequalorimage",
                                "2253imageorapproximatelyequal",
                                "2260notequal",
                                "2261equivalence",
                                "2262notidentical",
                                "2264lessequal",
                                "2265greaterequal",
                                "2266lessoverequal",
                                "2267greateroverequal",
                                "226Amuchless",
                                "226Bmuchgreater",
                                "226Enotless",
                                "226Fnotgreater",
                                "2270notlessnorequal",
                                "2271notgreaternorequal",
                                "2272lessorequivalent",
                                "2273greaterorequivalent",
                                "2276lessorgreater",
                                "2277greaterorless",
                                "2279notgreaternorless",
                                "227Aprecedes",
                                "227Bsucceeds",
                                "2280notprecedes",
                                "2281notsucceeds",
                                "2282propersubset",
                                "2283propersuperset",
                                "2284notsubset",
                                "2285notsuperset",
                                "2286reflexsubset",
                                "2287reflexsuperset",
                                "228Asubsetnotequal",
                                "228Bsupersetnotequal",
                                "2295circleplus",
                                "2296minuscircle",
                                "2297circlemultiply",
                                "2299circleot",
                                "22A3tackleft",
                                "22A4tackdown",
                                "22A5perpendicular",
                                "22BFrighttriangle",
                                "22C5dotmath",
                                "22CEcurlyor",
                                "22CFcurlyand",
                                "22DAlessequalorgreater",
                                "22DBgreaterequalorless",
                                "22EEellipsisvertical",
                                "F6BEdotlessj",
                                "F6BFLL",
                                "F6C0ll",
                                "F6C3commaaccent",
                                "F6C4afii10063",
                                "F6C5afii10064",
                                "F6C6afii10192",
                                "F6C7afii10831",
                                "F6C8afii10832",
                                "F6C9Acute",
                                "F6CACaron",
                                "F6CBDieresis",
                                "F6CCDieresisAcute",
                                "F6CDDieresisGrave",
                                "F6CEGrave",
                                "F6CFHungarumlaut",
                                "F6D0Macron",
                                "F6D1cyrBreve",
                                "F6D2cyrFlex",
                                "F6D3dblGrave",
                                "F6D4cyrbreve",
                                "F6D5cyrflex",
                                "F6D6dblgrave",
                                "F6D7dieresisacute",
                                "F6D8dieresisgrave",
                                "F6D9copyrightserif",
                                "F6DAregisterserif",
                                "F6DBtrademarkserif",
                                "F6DConefitted",
                                "F6DDrupiah",
                                "F8FFapple",
                                "FB00ff",
                                "FB01fi",
                                "FB02fl",
                                "FB03ffi",
                                "FB04ffl",
                                "FE61asterisksmall",
                                "FE62plussmall",
                                "FE63hyphensmall",
                                "FE64lesssmall",
                                "FE65greatersmall",
                                "FE66equalsmall",
                                "FE69dollarsmall",
                                "FE6Apercentsmall",
                                "FE6Batsmall",
                                // for font "Symbols"
                                "F020space",
                                "F021exclam",
                                "F022universal",
                                "F023numbersign",
                                "F024existential",
                                "F025percent",
                                "F026ampersand",
                                "F027suchthat",
                                "F028parenleft",
                                "F029parenright",
                                "F02Aasteriskmath",
                                "F02Bplus",
                                "F02Ccomma",
                                "F02Dminus",
                                "F02Eperiod",
                                "F02Fslash",
                                "F030zero",
                                "F031one",
                                "F032two",
                                "F033three",
                                "F034four",
                                "F035five",
                                "F036six",
                                "F037seven",
                                "F038eight",
                                "F039nine",
                                "F03Acolon",
                                "F03Bsemicolon",
                                "F03Cless",
                                "F03Dequal",
                                "F03Egreater",
                                "F03Fquestion",
                                "F040congruent",
                                "F041Alpha",
                                "F042Beta",
                                "F043Chi",
                                "F044Delta",
                                "F045Epsilon",
                                "F046Phi",
                                "F047Gamma",
                                "F048Eta",
                                "F049Iota",
                                "F04Atheta1",
                                "F04BKappa",
                                "F04CLambda",
                                "F04DMu",
                                "F04ENu",
                                "F04FOmicron",
                                "F050Pi",
                                "F051Theta",
                                "F052Rho",
                                "F053Sigma",
                                "F054Tau",
                                "F055Upsilon",
                                "F056sigma1",
                                "F057Omega",
                                "F058Xi",
                                "F059Psi",
                                "F05AZeta",
                                "F05Bbracketleft",
                                "F05Ctherefore",
                                "F05Dbracketright",
                                "F05Eperpendicular",
                                "F05Funderscore",
                                "F060radicalex",
                                "F061alpha",
                                "F062beta",
                                "F063chi",
                                "F064delta",
                                "F065epsilon",
                                "F066phi",
                                "F067gamma",
                                "F068eta",
                                "F069iota",
                                "F06Aphi1",
                                "F06Bkappa",
                                "F06Clambda",
                                "F06Dmu",
                                "F06Enu",
                                "F06Fomicron",
                                "F070pi",
                                "F071theta",
                                "F072rho",
                                "F073sigma",
                                "F074tau",
                                "F075upsilon",
                                "F076omega1",
                                "F077omega",
                                "F078xi",
                                "F079psi",
                                "F07Azeta",
                                "F07Bbraceleft",
                                "F07Cbar",
                                "F07Dbraceright",
                                "F07Esimilar",
                                "F0A0Euro",
                                "F0A1Upsilon1",
                                "F0A2minute",
                                "F0A3lessequal",
                                "F0A4fraction",
                                "F0A5infinity",
                                "F0A6florin",
                                "F0A7club",
                                "F0A8diamond",
                                "F0A9heart",
                                "F0AAspade",
                                "F0ABarrowboth",
                                "F0ACarrowleft",
                                "F0ADarrowup",
                                "F0AEarrowright",
                                "F0AFarrowdown",
                                "F0B0degree",
                                "F0B1plusminus",
                                "F0B2second",
                                "F0B3greaterequal",
                                "F0B4multiply",
                                "F0B5proportional",
                                "F0B6partialdiff",
                                "F0B7bullet",
                                "F0B8divide",
                                "F0B9notequal",
                                "F0BAequivalence",
                                "F0BBapproxequal",
                                "F0BCellipsis",
                                "F0BDarrowvertex",
                                "F0BEarrowhorizex",
                                "F0BFcarriagereturn",
                                "F0C0aleph",
                                "F0C1Ifraktur",
                                "F0C2Rfraktur",
                                "F0C3weierstrass",
                                "F0C4circlemultiply",
                                "F0C5circleplus",
                                "F0C6emptyset",
                                "F0C7intersection",
                                "F0C8union",
                                "F0C9propersuperset",
                                "F0CAreflexsuperset",
                                "F0CBnotsubset",
                                "F0CCpropersubset",
                                "F0CDreflexsubset",
                                "F0CEelement",
                                "F0CFnotelement",
                                "F0D0angle",
                                "F0D1gradient",
                                "F0D2registerserif",
                                "F0D3copyrightserif",
                                "F0D4trademarkserif",
                                "F0D5product",
                                "F0D6radical",
                                "F0D7dotmath",
                                "F0D8logicalnot",
                                "F0D9logicaland",
                                "F0DAlogicalor",
                                "F0DBarrowdblboth",
                                "F0DCarrowdblleft",
                                "F0DDarrowdblup",
                                "F0DEarrowdblright",
                                "F0DFarrowdbldown",
                                "F0E0lozenge",
                                "F0E1angleleft",
                                "F0E2registersans",
                                "F0E3copyrightsans",
                                "F0E4trademarksans",
                                "F0E5summation",
                                "F0E6parenlefttp",
                                "F0E7parenleftex",
                                "F0E8parenleftbt",
                                "F0E9bracketlefttp",
                                "F0EAbracketleftex",
                                "F0EBbracketleftbt",
                                "F0ECbracelefttp",
                                "F0EDbraceleftmid",
                                "F0EEbraceleftbt",
                                "F0EFbraceex",
                                "F0F1angleright",
                                "F0F2integral",
                                "F0F3integraltp",
                                "F0F4integralex",
                                "F0F5integralbt",
                                "F0F6parenrighttp",
                                "F0F7parenrightex",
                                "F0F8parenrightbt",
                                "F0F9bracketrighttp",
                                "F0FAbracketrightex",
                                "F0FBbracketrightbt",
                                "F0FCbracerighttp",
                                "F0FDbracerightmid",
                                "F0FEbracerightbt"
                            ];
                            this._standardFontCharsNames = [];
                            for (var indexTemp = 0; indexTemp < charsNames.length; indexTemp++) {
                                var code = parseInt(charsNames[indexTemp].substr(0, 4), 16);
                                this._standardFontCharsNames[code] = charsNames[indexTemp].substr(4);
                            }
                        }
                        return this._standardFontCharsNames;
                    },
                    enumerable: true,
                    configurable: true
                });
                StiPdfResources.sRGBprofile = [
                    0, 0, 12, 72, 76, 105, 110, 111, 2, 16, 0, 0, 109, 110, 116, 114,
                    82, 71, 66, 32, 88, 89, 90, 32, 7, 206, 0, 2, 0, 9, 0, 6,
                    0, 49, 0, 0, 97, 99, 115, 112, 77, 83, 70, 84, 0, 0, 0, 0,
                    73, 69, 67, 32, 115, 82, 71, 66, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 246, 214, 0, 1, 0, 0, 0, 0, 211, 45,
                    72, 80, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 17, 99, 112, 114, 116, 0, 0, 1, 80, 0, 0, 0, 51,
                    100, 101, 115, 99, 0, 0, 1, 132, 0, 0, 0, 108, 119, 116, 112, 116,
                    0, 0, 1, 240, 0, 0, 0, 20, 98, 107, 112, 116, 0, 0, 2, 4,
                    0, 0, 0, 20, 114, 88, 89, 90, 0, 0, 2, 24, 0, 0, 0, 20,
                    103, 88, 89, 90, 0, 0, 2, 44, 0, 0, 0, 20, 98, 88, 89, 90,
                    0, 0, 2, 64, 0, 0, 0, 20, 100, 109, 110, 100, 0, 0, 2, 84,
                    0, 0, 0, 112, 100, 109, 100, 100, 0, 0, 2, 196, 0, 0, 0, 136,
                    118, 117, 101, 100, 0, 0, 3, 76, 0, 0, 0, 134, 118, 105, 101, 119,
                    0, 0, 3, 212, 0, 0, 0, 36, 108, 117, 109, 105, 0, 0, 3, 248,
                    0, 0, 0, 20, 109, 101, 97, 115, 0, 0, 4, 12, 0, 0, 0, 36,
                    116, 101, 99, 104, 0, 0, 4, 48, 0, 0, 0, 12, 114, 84, 82, 67,
                    0, 0, 4, 60, 0, 0, 8, 12, 103, 84, 82, 67, 0, 0, 4, 60,
                    0, 0, 8, 12, 98, 84, 82, 67, 0, 0, 4, 60, 0, 0, 8, 12,
                    116, 101, 120, 116, 0, 0, 0, 0, 67, 111, 112, 121, 114, 105, 103, 104,
                    116, 32, 40, 99, 41, 32, 49, 57, 57, 56, 32, 72, 101, 119, 108, 101,
                    116, 116, 45, 80, 97, 99, 107, 97, 114, 100, 32, 67, 111, 109, 112, 97,
                    110, 121, 0, 0, 100, 101, 115, 99, 0, 0, 0, 0, 0, 0, 0, 18,
                    115, 82, 71, 66, 32, 73, 69, 67, 54, 49, 57, 54, 54, 45, 50, 46,
                    49, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 115, 82, 71,
                    66, 32, 73, 69, 67, 54, 49, 57, 54, 54, 45, 50, 46, 49, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    88, 89, 90, 32, 0, 0, 0, 0, 0, 0, 243, 81, 0, 1, 0, 0,
                    0, 1, 22, 204, 88, 89, 90, 32, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 88, 89, 90, 32, 0, 0, 0, 0,
                    0, 0, 111, 162, 0, 0, 56, 245, 0, 0, 3, 144, 88, 89, 90, 32,
                    0, 0, 0, 0, 0, 0, 98, 153, 0, 0, 183, 133, 0, 0, 24, 218,
                    88, 89, 90, 32, 0, 0, 0, 0, 0, 0, 36, 160, 0, 0, 15, 132,
                    0, 0, 182, 207, 100, 101, 115, 99, 0, 0, 0, 0, 0, 0, 0, 22,
                    73, 69, 67, 32, 104, 116, 116, 112, 58, 47, 47, 119, 119, 119, 46, 105,
                    101, 99, 46, 99, 104, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    22, 73, 69, 67, 32, 104, 116, 116, 112, 58, 47, 47, 119, 119, 119, 46,
                    105, 101, 99, 46, 99, 104, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 100, 101, 115, 99, 0, 0, 0, 0, 0, 0, 0, 46,
                    73, 69, 67, 32, 54, 49, 57, 54, 54, 45, 50, 46, 49, 32, 68, 101,
                    102, 97, 117, 108, 116, 32, 82, 71, 66, 32, 99, 111, 108, 111, 117, 114,
                    32, 115, 112, 97, 99, 101, 32, 45, 32, 115, 82, 71, 66, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 46, 73, 69, 67, 32, 54, 49, 57,
                    54, 54, 45, 50, 46, 49, 32, 68, 101, 102, 97, 117, 108, 116, 32, 82,
                    71, 66, 32, 99, 111, 108, 111, 117, 114, 32, 115, 112, 97, 99, 101, 32,
                    45, 32, 115, 82, 71, 66, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 101, 115, 99,
                    0, 0, 0, 0, 0, 0, 0, 44, 82, 101, 102, 101, 114, 101, 110, 99,
                    101, 32, 86, 105, 101, 119, 105, 110, 103, 32, 67, 111, 110, 100, 105, 116,
                    105, 111, 110, 32, 105, 110, 32, 73, 69, 67, 54, 49, 57, 54, 54, 45,
                    50, 46, 49, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 44, 82,
                    101, 102, 101, 114, 101, 110, 99, 101, 32, 86, 105, 101, 119, 105, 110, 103,
                    32, 67, 111, 110, 100, 105, 116, 105, 111, 110, 32, 105, 110, 32, 73, 69,
                    67, 54, 49, 57, 54, 54, 45, 50, 46, 49, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 118, 105, 101, 119, 0, 0, 0, 0, 0, 19, 164, 254,
                    0, 20, 95, 46, 0, 16, 207, 20, 0, 3, 237, 204, 0, 4, 19, 11,
                    0, 3, 92, 158, 0, 0, 0, 1, 88, 89, 90, 32, 0, 0, 0, 0,
                    0, 76, 9, 86, 0, 80, 0, 0, 0, 87, 31, 231, 109, 101, 97, 115,
                    0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 143, 0, 0, 0, 2,
                    115, 105, 103, 32, 0, 0, 0, 0, 67, 82, 84, 32, 99, 117, 114, 118,
                    0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 5, 0, 10, 0, 15,
                    0, 20, 0, 25, 0, 30, 0, 35, 0, 40, 0, 45, 0, 50, 0, 55,
                    0, 59, 0, 64, 0, 69, 0, 74, 0, 79, 0, 84, 0, 89, 0, 94,
                    0, 99, 0, 104, 0, 109, 0, 114, 0, 119, 0, 124, 0, 129, 0, 134,
                    0, 139, 0, 144, 0, 149, 0, 154, 0, 159, 0, 164, 0, 169, 0, 174,
                    0, 178, 0, 183, 0, 188, 0, 193, 0, 198, 0, 203, 0, 208, 0, 213,
                    0, 219, 0, 224, 0, 229, 0, 235, 0, 240, 0, 246, 0, 251, 1, 1,
                    1, 7, 1, 13, 1, 19, 1, 25, 1, 31, 1, 37, 1, 43, 1, 50,
                    1, 56, 1, 62, 1, 69, 1, 76, 1, 82, 1, 89, 1, 96, 1, 103,
                    1, 110, 1, 117, 1, 124, 1, 131, 1, 139, 1, 146, 1, 154, 1, 161,
                    1, 169, 1, 177, 1, 185, 1, 193, 1, 201, 1, 209, 1, 217, 1, 225,
                    1, 233, 1, 242, 1, 250, 2, 3, 2, 12, 2, 20, 2, 29, 2, 38,
                    2, 47, 2, 56, 2, 65, 2, 75, 2, 84, 2, 93, 2, 103, 2, 113,
                    2, 122, 2, 132, 2, 142, 2, 152, 2, 162, 2, 172, 2, 182, 2, 193,
                    2, 203, 2, 213, 2, 224, 2, 235, 2, 245, 3, 0, 3, 11, 3, 22,
                    3, 33, 3, 45, 3, 56, 3, 67, 3, 79, 3, 90, 3, 102, 3, 114,
                    3, 126, 3, 138, 3, 150, 3, 162, 3, 174, 3, 186, 3, 199, 3, 211,
                    3, 224, 3, 236, 3, 249, 4, 6, 4, 19, 4, 32, 4, 45, 4, 59,
                    4, 72, 4, 85, 4, 99, 4, 113, 4, 126, 4, 140, 4, 154, 4, 168,
                    4, 182, 4, 196, 4, 211, 4, 225, 4, 240, 4, 254, 5, 13, 5, 28,
                    5, 43, 5, 58, 5, 73, 5, 88, 5, 103, 5, 119, 5, 134, 5, 150,
                    5, 166, 5, 181, 5, 197, 5, 213, 5, 229, 5, 246, 6, 6, 6, 22,
                    6, 39, 6, 55, 6, 72, 6, 89, 6, 106, 6, 123, 6, 140, 6, 157,
                    6, 175, 6, 192, 6, 209, 6, 227, 6, 245, 7, 7, 7, 25, 7, 43,
                    7, 61, 7, 79, 7, 97, 7, 116, 7, 134, 7, 153, 7, 172, 7, 191,
                    7, 210, 7, 229, 7, 248, 8, 11, 8, 31, 8, 50, 8, 70, 8, 90,
                    8, 110, 8, 130, 8, 150, 8, 170, 8, 190, 8, 210, 8, 231, 8, 251,
                    9, 16, 9, 37, 9, 58, 9, 79, 9, 100, 9, 121, 9, 143, 9, 164,
                    9, 186, 9, 207, 9, 229, 9, 251, 10, 17, 10, 39, 10, 61, 10, 84,
                    10, 106, 10, 129, 10, 152, 10, 174, 10, 197, 10, 220, 10, 243, 11, 11,
                    11, 34, 11, 57, 11, 81, 11, 105, 11, 128, 11, 152, 11, 176, 11, 200,
                    11, 225, 11, 249, 12, 18, 12, 42, 12, 67, 12, 92, 12, 117, 12, 142,
                    12, 167, 12, 192, 12, 217, 12, 243, 13, 13, 13, 38, 13, 64, 13, 90,
                    13, 116, 13, 142, 13, 169, 13, 195, 13, 222, 13, 248, 14, 19, 14, 46,
                    14, 73, 14, 100, 14, 127, 14, 155, 14, 182, 14, 210, 14, 238, 15, 9,
                    15, 37, 15, 65, 15, 94, 15, 122, 15, 150, 15, 179, 15, 207, 15, 236,
                    16, 9, 16, 38, 16, 67, 16, 97, 16, 126, 16, 155, 16, 185, 16, 215,
                    16, 245, 17, 19, 17, 49, 17, 79, 17, 109, 17, 140, 17, 170, 17, 201,
                    17, 232, 18, 7, 18, 38, 18, 69, 18, 100, 18, 132, 18, 163, 18, 195,
                    18, 227, 19, 3, 19, 35, 19, 67, 19, 99, 19, 131, 19, 164, 19, 197,
                    19, 229, 20, 6, 20, 39, 20, 73, 20, 106, 20, 139, 20, 173, 20, 206,
                    20, 240, 21, 18, 21, 52, 21, 86, 21, 120, 21, 155, 21, 189, 21, 224,
                    22, 3, 22, 38, 22, 73, 22, 108, 22, 143, 22, 178, 22, 214, 22, 250,
                    23, 29, 23, 65, 23, 101, 23, 137, 23, 174, 23, 210, 23, 247, 24, 27,
                    24, 64, 24, 101, 24, 138, 24, 175, 24, 213, 24, 250, 25, 32, 25, 69,
                    25, 107, 25, 145, 25, 183, 25, 221, 26, 4, 26, 42, 26, 81, 26, 119,
                    26, 158, 26, 197, 26, 236, 27, 20, 27, 59, 27, 99, 27, 138, 27, 178,
                    27, 218, 28, 2, 28, 42, 28, 82, 28, 123, 28, 163, 28, 204, 28, 245,
                    29, 30, 29, 71, 29, 112, 29, 153, 29, 195, 29, 236, 30, 22, 30, 64,
                    30, 106, 30, 148, 30, 190, 30, 233, 31, 19, 31, 62, 31, 105, 31, 148,
                    31, 191, 31, 234, 32, 21, 32, 65, 32, 108, 32, 152, 32, 196, 32, 240,
                    33, 28, 33, 72, 33, 117, 33, 161, 33, 206, 33, 251, 34, 39, 34, 85,
                    34, 130, 34, 175, 34, 221, 35, 10, 35, 56, 35, 102, 35, 148, 35, 194,
                    35, 240, 36, 31, 36, 77, 36, 124, 36, 171, 36, 218, 37, 9, 37, 56,
                    37, 104, 37, 151, 37, 199, 37, 247, 38, 39, 38, 87, 38, 135, 38, 183,
                    38, 232, 39, 24, 39, 73, 39, 122, 39, 171, 39, 220, 40, 13, 40, 63,
                    40, 113, 40, 162, 40, 212, 41, 6, 41, 56, 41, 107, 41, 157, 41, 208,
                    42, 2, 42, 53, 42, 104, 42, 155, 42, 207, 43, 2, 43, 54, 43, 105,
                    43, 157, 43, 209, 44, 5, 44, 57, 44, 110, 44, 162, 44, 215, 45, 12,
                    45, 65, 45, 118, 45, 171, 45, 225, 46, 22, 46, 76, 46, 130, 46, 183,
                    46, 238, 47, 36, 47, 90, 47, 145, 47, 199, 47, 254, 48, 53, 48, 108,
                    48, 164, 48, 219, 49, 18, 49, 74, 49, 130, 49, 186, 49, 242, 50, 42,
                    50, 99, 50, 155, 50, 212, 51, 13, 51, 70, 51, 127, 51, 184, 51, 241,
                    52, 43, 52, 101, 52, 158, 52, 216, 53, 19, 53, 77, 53, 135, 53, 194,
                    53, 253, 54, 55, 54, 114, 54, 174, 54, 233, 55, 36, 55, 96, 55, 156,
                    55, 215, 56, 20, 56, 80, 56, 140, 56, 200, 57, 5, 57, 66, 57, 127,
                    57, 188, 57, 249, 58, 54, 58, 116, 58, 178, 58, 239, 59, 45, 59, 107,
                    59, 170, 59, 232, 60, 39, 60, 101, 60, 164, 60, 227, 61, 34, 61, 97,
                    61, 161, 61, 224, 62, 32, 62, 96, 62, 160, 62, 224, 63, 33, 63, 97,
                    63, 162, 63, 226, 64, 35, 64, 100, 64, 166, 64, 231, 65, 41, 65, 106,
                    65, 172, 65, 238, 66, 48, 66, 114, 66, 181, 66, 247, 67, 58, 67, 125,
                    67, 192, 68, 3, 68, 71, 68, 138, 68, 206, 69, 18, 69, 85, 69, 154,
                    69, 222, 70, 34, 70, 103, 70, 171, 70, 240, 71, 53, 71, 123, 71, 192,
                    72, 5, 72, 75, 72, 145, 72, 215, 73, 29, 73, 99, 73, 169, 73, 240,
                    74, 55, 74, 125, 74, 196, 75, 12, 75, 83, 75, 154, 75, 226, 76, 42,
                    76, 114, 76, 186, 77, 2, 77, 74, 77, 147, 77, 220, 78, 37, 78, 110,
                    78, 183, 79, 0, 79, 73, 79, 147, 79, 221, 80, 39, 80, 113, 80, 187,
                    81, 6, 81, 80, 81, 155, 81, 230, 82, 49, 82, 124, 82, 199, 83, 19,
                    83, 95, 83, 170, 83, 246, 84, 66, 84, 143, 84, 219, 85, 40, 85, 117,
                    85, 194, 86, 15, 86, 92, 86, 169, 86, 247, 87, 68, 87, 146, 87, 224,
                    88, 47, 88, 125, 88, 203, 89, 26, 89, 105, 89, 184, 90, 7, 90, 86,
                    90, 166, 90, 245, 91, 69, 91, 149, 91, 229, 92, 53, 92, 134, 92, 214,
                    93, 39, 93, 120, 93, 201, 94, 26, 94, 108, 94, 189, 95, 15, 95, 97,
                    95, 179, 96, 5, 96, 87, 96, 170, 96, 252, 97, 79, 97, 162, 97, 245,
                    98, 73, 98, 156, 98, 240, 99, 67, 99, 151, 99, 235, 100, 64, 100, 148,
                    100, 233, 101, 61, 101, 146, 101, 231, 102, 61, 102, 146, 102, 232, 103, 61,
                    103, 147, 103, 233, 104, 63, 104, 150, 104, 236, 105, 67, 105, 154, 105, 241,
                    106, 72, 106, 159, 106, 247, 107, 79, 107, 167, 107, 255, 108, 87, 108, 175,
                    109, 8, 109, 96, 109, 185, 110, 18, 110, 107, 110, 196, 111, 30, 111, 120,
                    111, 209, 112, 43, 112, 134, 112, 224, 113, 58, 113, 149, 113, 240, 114, 75,
                    114, 166, 115, 1, 115, 93, 115, 184, 116, 20, 116, 112, 116, 204, 117, 40,
                    117, 133, 117, 225, 118, 62, 118, 155, 118, 248, 119, 86, 119, 179, 120, 17,
                    120, 110, 120, 204, 121, 42, 121, 137, 121, 231, 122, 70, 122, 165, 123, 4,
                    123, 99, 123, 194, 124, 33, 124, 129, 124, 225, 125, 65, 125, 161, 126, 1,
                    126, 98, 126, 194, 127, 35, 127, 132, 127, 229, 128, 71, 128, 168, 129, 10,
                    129, 107, 129, 205, 130, 48, 130, 146, 130, 244, 131, 87, 131, 186, 132, 29,
                    132, 128, 132, 227, 133, 71, 133, 171, 134, 14, 134, 114, 134, 215, 135, 59,
                    135, 159, 136, 4, 136, 105, 136, 206, 137, 51, 137, 153, 137, 254, 138, 100,
                    138, 202, 139, 48, 139, 150, 139, 252, 140, 99, 140, 202, 141, 49, 141, 152,
                    141, 255, 142, 102, 142, 206, 143, 54, 143, 158, 144, 6, 144, 110, 144, 214,
                    145, 63, 145, 168, 146, 17, 146, 122, 146, 227, 147, 77, 147, 182, 148, 32,
                    148, 138, 148, 244, 149, 95, 149, 201, 150, 52, 150, 159, 151, 10, 151, 117,
                    151, 224, 152, 76, 152, 184, 153, 36, 153, 144, 153, 252, 154, 104, 154, 213,
                    155, 66, 155, 175, 156, 28, 156, 137, 156, 247, 157, 100, 157, 210, 158, 64,
                    158, 174, 159, 29, 159, 139, 159, 250, 160, 105, 160, 216, 161, 71, 161, 182,
                    162, 38, 162, 150, 163, 6, 163, 118, 163, 230, 164, 86, 164, 199, 165, 56,
                    165, 169, 166, 26, 166, 139, 166, 253, 167, 110, 167, 224, 168, 82, 168, 196,
                    169, 55, 169, 169, 170, 28, 170, 143, 171, 2, 171, 117, 171, 233, 172, 92,
                    172, 208, 173, 68, 173, 184, 174, 45, 174, 161, 175, 22, 175, 139, 176, 0,
                    176, 117, 176, 234, 177, 96, 177, 214, 178, 75, 178, 194, 179, 56, 179, 174,
                    180, 37, 180, 156, 181, 19, 181, 138, 182, 1, 182, 121, 182, 240, 183, 104,
                    183, 224, 184, 89, 184, 209, 185, 74, 185, 194, 186, 59, 186, 181, 187, 46,
                    187, 167, 188, 33, 188, 155, 189, 21, 189, 143, 190, 10, 190, 132, 190, 255,
                    191, 122, 191, 245, 192, 112, 192, 236, 193, 103, 193, 227, 194, 95, 194, 219,
                    195, 88, 195, 212, 196, 81, 196, 206, 197, 75, 197, 200, 198, 70, 198, 195,
                    199, 65, 199, 191, 200, 61, 200, 188, 201, 58, 201, 185, 202, 56, 202, 183,
                    203, 54, 203, 182, 204, 53, 204, 181, 205, 53, 205, 181, 206, 54, 206, 182,
                    207, 55, 207, 184, 208, 57, 208, 186, 209, 60, 209, 190, 210, 63, 210, 193,
                    211, 68, 211, 198, 212, 73, 212, 203, 213, 78, 213, 209, 214, 85, 214, 216,
                    215, 92, 215, 224, 216, 100, 216, 232, 217, 108, 217, 241, 218, 118, 218, 251,
                    219, 128, 220, 5, 220, 138, 221, 16, 221, 150, 222, 28, 222, 162, 223, 41,
                    223, 175, 224, 54, 224, 189, 225, 68, 225, 204, 226, 83, 226, 219, 227, 99,
                    227, 235, 228, 115, 228, 252, 229, 132, 230, 13, 230, 150, 231, 31, 231, 169,
                    232, 50, 232, 188, 233, 70, 233, 208, 234, 91, 234, 229, 235, 112, 235, 251,
                    236, 134, 237, 17, 237, 156, 238, 40, 238, 180, 239, 64, 239, 204, 240, 88,
                    240, 229, 241, 114, 241, 255, 242, 140, 243, 25, 243, 167, 244, 52, 244, 194,
                    245, 80, 245, 222, 246, 109, 246, 251, 247, 138, 248, 25, 248, 168, 249, 56,
                    249, 199, 250, 87, 250, 231, 251, 119, 252, 7, 252, 152, 253, 41, 253, 186,
                    254, 75, 254, 220, 255, 109, 255, 255
                ];
                StiPdfResources.hatchData = [
                    "000000FF00000000",
                    "1010101010101010",
                    "8040201008040201",
                    "0102040810204080",
                    "101010FF10101010",
                    "8142241818244281",
                    "8000000008000000",
                    "0010000100100001",
                    "2200880022008800",
                    "2288228822882288",
                    "2255885522558855",
                    "AA558A55AA55A855",
                    "AA55AA55AA55AA55",
                    "BB55EE55BB55EE55",
                    "DD77DD77DD77DD77",
                    "FFDDFF77FFDDFF77",
                    "FF7FFFF7FF7FFFF7",
                    "FF7FFFFFFFF7FFFF",
                    "8844221188442211",
                    "1122448811224488",
                    "CC663399CC663399",
                    "993366CC993366CC",
                    "E070381C0E0783C1",
                    "C183070E1C3870E0",
                    "4040404040404040",
                    "00FF000000FF0000",
                    "AAAAAAAAAAAAAAAA",
                    "FF00FF00FF00FF00",
                    "CCCCCCCCCCCCCCCC",
                    "FFFF0000FFFF0000",
                    "8844221100000000",
                    "1122448800000000",
                    "F00000000F000000",
                    "8080808008080808",
                    "0240088004200110",
                    "0C8DB130031BD8C0",
                    "8403304884033048",
                    "00304A8100304A81",
                    "0102040818244281",
                    "202020FF020202FF",
                    "1422518854224588",
                    "F0F0F0F0AA55AA55",
                    "0100201020000102",
                    "AA00800080008000",
                    "0020008800020088",
                    "8448300C02010103",
                    "33FFCCFF33FFCCFF",
                    "98F8F877898F8F77",
                    "111111FF111111FF",
                    "3333CCCC3333CCCC",
                    "0F0F0F0FF0F0F0F0",
                    "0502058850205088",
                    "10387CFE7C381000",
                    "0000000000000000" // HatchStyleTotal = 53
                ];
                StiPdfResources.standardFontWidths = null;
                StiPdfResources.standardFontInfo = null;
                StiPdfResources._standardFontCharsNames = null;
                return StiPdfResources;
            }());
            Export.StiPdfResources = StiPdfResources;
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
            var StiPdfSecurity = /** @class */ (function () {
                function StiPdfSecurity(service) {
                    this.ownerValue = []; // new number[48];
                    this.userValue = []; // new number[48];
                    this.ownerExtendedValue = []; // number[] = new number[32];
                    this.userExtendedValue = []; // new number[32];
                    this.permsValue = []; // new number[16];
                    this.IDValue = null;
                    this.encryptionKey = null;
                    this.encryptionKeyLength = 0;
                    this.passwordOwner = "";
                    this.passwordUser = "";
                    this.securityFlags = 0; // uint
                    this.keyLength = Export.StiPdfEncryptionKeyLength.Bit40;
                    this.pdfService = null;
                    this.pdfService = service;
                }
                //#region Pad Password
                StiPdfSecurity.prototype.padPassword = function (inputPassword) {
                    var password = [];
                    var index = 0;
                    for (; index < inputPassword.length; index++) {
                        password[index] = inputPassword.charCodeAt(index);
                    }
                    for (var index2 = 0; index2 < StiPdfSecurity.paddingString.length; index2++) {
                        password[index++] = StiPdfSecurity.paddingString[index2];
                    }
                    var result = [];
                    for (index = 0; index < 32; index++) {
                        result[index] = password[index];
                    }
                    return result;
                };
                //#endregion
                //#region ComputingCryptoValues
                StiPdfSecurity.prototype.computingCryptoValues = function (userAccessPrivileges, passwordInputOwner, passwordInputUser, keyLength, IDValue) {
                    this.securityFlags = 0xFFFFFFC0; // none for revision 2
                    var tempFlags = 0x00000000;
                    if ((userAccessPrivileges & Export.StiUserAccessPrivileges.PrintDocument) != 0)
                        tempFlags |= 1 << 2;
                    if ((userAccessPrivileges & Export.StiUserAccessPrivileges.ModifyContents) != 0)
                        tempFlags |= 1 << 3;
                    if ((userAccessPrivileges & Export.StiUserAccessPrivileges.CopyTextAndGraphics) != 0)
                        tempFlags |= 1 << 4;
                    if ((userAccessPrivileges & Export.StiUserAccessPrivileges.AddOrModifyTextAnnotations) != 0)
                        tempFlags |= 1 << 5;
                    this.securityFlags |= tempFlags;
                    if (passwordInputOwner == null)
                        passwordInputOwner = "";
                    if (passwordInputUser == null)
                        passwordInputUser = "";
                    this.passwordOwner = passwordInputOwner;
                    this.passwordUser = passwordInputUser;
                    this.keyLength = keyLength;
                    this.IDValue = IDValue;
                    var encrypted = false;
                    if ((this.passwordOwner.length > 0) || (this.passwordUser.length > 0) || (userAccessPrivileges != Export.StiUserAccessPrivileges.All)) {
                        encrypted = true;
                        var error = this.computingCryptoValues2();
                        if (!error) {
                            encrypted = false; // encrypt not work
                            this.throwEncryptionError(0, "Encryption not work!");
                        }
                    }
                    return encrypted;
                };
                StiPdfSecurity.prototype.computingCryptoValues2 = function () {
                    if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit128_r4)
                        return this.computingCryptoValuesV4();
                    if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit256_r5 || this.keyLength == Export.StiPdfEncryptionKeyLength.Bit256_r6)
                        return this.сomputingCryptoValuesV5();
                    var password = this.passwordOwner;
                    if (StiString.isNullOrEmpty(this.passwordOwner))
                        password = this.passwordUser;
                    var pass1 = this.padPassword(password);
                    //#region compute owner value
                    // add data to hash
                    var hash = this.computeHashMD5(pass1);
                    if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit128) {
                        // for release 3
                        for (var index1 = 0; index1 < 50; index1++) {
                            hash = this.computeHashMD5(hash);
                        }
                    }
                    if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit40) {
                        var buf = []; // new byte[5];
                        buf[0] = hash[0];
                        buf[1] = hash[1];
                        buf[2] = hash[2];
                        buf[3] = hash[3];
                        buf[4] = hash[4];
                        hash = buf;
                    }
                    var result1 = this.padPassword(this.passwordUser);
                    // encrypt the user password
                    result1 = this.rc4(result1, hash);
                    if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit128) {
                        // for release 3
                        for (var index2 = 1; index2 <= 19; index2++) {
                            for (var tempIndex = 0; tempIndex < 16; tempIndex++) {
                                hash[tempIndex] ^= (index2 - 1);
                                hash[tempIndex] ^= index2;
                            }
                            result1 = this.rc4(result1, hash);
                        }
                    }
                    result1.copyTo(this.ownerValue, 0);
                    //#endregion
                    //#region compute encryption key and user value
                    var password2 = this.passwordUser;
                    var pass2 = this.padPassword(password2);
                    var pp = this.getBytesUInt32(this.securityFlags);
                    var ms = [];
                    ms.addRange(pass2);
                    ms.addRange(result1);
                    ms.addRange(pp);
                    ms.addRange(this.IDValue);
                    hash = this.computeHashMD5(ms);
                    if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit128) {
                        // for release 3
                        for (var index1 = 0; index1 < 50; index1++) {
                            hash = this.computeHashMD5(hash);
                        }
                    }
                    // create encryption key
                    this.encryptionKey = [];
                    this.encryptionKeyLength = (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit128) ? 16 : 5;
                    for (var index = 0; index < this.encryptionKeyLength; index++) {
                        this.encryptionKey[index] = hash[index];
                    }
                    var result2 = []; // new byte[32];
                    if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit128) {
                        //#region for release 3
                        ms = [];
                        ms.addRange(StiPdfSecurity.paddingString);
                        ms.addRange(this.IDValue);
                        hash = this.computeHashMD5(ms);
                        hash = this.rc4(hash, this.encryptionKey);
                        var newKey = []; // new byte[16];
                        for (var index2 = 1; index2 <= 19; index2++) {
                            for (var tempIndex = 0; tempIndex < 16; tempIndex++) {
                                newKey[tempIndex] = this.encryptionKey[tempIndex] ^ index2;
                            }
                            hash = this.rc4(hash, newKey);
                        }
                        StiPdfSecurity.paddingString.copyTo(result2, 0);
                        hash.copyTo(result2, 0);
                        //#endregion
                    }
                    else {
                        //#region for release 2
                        StiPdfSecurity.paddingString.copyTo(result2, 0);
                        // encrypt the user password
                        result2 = this.rc4(result2, this.encryptionKey);
                        //#endregion
                    }
                    result2.copyTo(this.userValue, 0);
                    //#endregion
                    return true;
                };
                StiPdfSecurity.prototype.computingCryptoValuesV4 = function () {
                    var password = this.passwordOwner;
                    if (StiString.isNullOrEmpty(this.passwordOwner))
                        password = this.passwordUser;
                    var pass1 = this.padPassword(password);
                    //#region compute owner value
                    // add data to hash
                    var hash = this.computeHashMD5(pass1);
                    for (var index1 = 0; index1 < 50; index1++) {
                        hash = this.computeHashMD5(hash);
                    }
                    var result1 = this.padPassword(this.passwordUser);
                    // encrypt the user password
                    result1 = this.rc4(result1, hash);
                    for (var index2 = 1; index2 <= 19; index2++) {
                        for (var tempIndex = 0; tempIndex < 16; tempIndex++) {
                            hash[tempIndex] ^= (index2 - 1);
                            hash[tempIndex] ^= index2;
                        }
                        result1 = this.rc4(result1, hash);
                    }
                    result1.copyTo(this.ownerValue, 0);
                    //#endregion
                    //#region compute encryption key and user value
                    var password2 = this.passwordUser;
                    var pass2 = this.padPassword(password2);
                    var pp = this.getBytesUInt32(this.securityFlags);
                    var ms = [];
                    ms.addRange(pass2);
                    ms.addRange(result1);
                    ms.addRange(pp);
                    ms.addRange(this.IDValue);
                    hash = this.computeHashMD5(ms);
                    for (var index1 = 0; index1 < 50; index1++) {
                        hash = this.computeHashMD5(hash);
                    }
                    // create encryption key
                    this.encryptionKey = [];
                    this.encryptionKeyLength = 16;
                    for (var index = 0; index < this.encryptionKeyLength; index++) {
                        this.encryptionKey[index] = hash[index];
                    }
                    var result2 = []; // new byte[32];
                    ms = [];
                    ms.addRange(StiPdfSecurity.paddingString);
                    ms.addRange(this.IDValue);
                    hash = this.computeHashMD5(ms);
                    hash = this.rc4(hash, this.encryptionKey);
                    var newKey = []; // new byte[16];
                    for (var index2 = 1; index2 <= 19; index2++) {
                        for (var tempIndex = 0; tempIndex < 16; tempIndex++) {
                            newKey[tempIndex] = this.encryptionKey[tempIndex] ^ index2;
                        }
                        hash = this.rc4(hash, newKey);
                    }
                    StiPdfSecurity.paddingString.copyTo(result2, 0);
                    hash.copyTo(result2, 0);
                    //#endregion
                    result2.copyTo(this.userValue, 0);
                    //#endregion
                    return true;
                };
                StiPdfSecurity.prototype.сomputingCryptoValuesV5 = function () {
                    var rnd = new Stimulsoft.System.Crypt.SecureRandom();
                    var buf = null;
                    var hash = null;
                    var baseEncryptionKey = rnd.createNextBytes(32); // new byte[32];
                    var userValidationSalt = rnd.createNextBytes(8);
                    var userKeySalt = rnd.createNextBytes(8);
                    var ownerValidationSalt = rnd.createNextBytes(8);
                    var ownerKeySalt = rnd.createNextBytes(8);
                    //#region Computing the encryption dictionary’s U(user password) and UE(user encryption key) values
                    var passUser = Stimulsoft.System.Text.Encoding.UTF8.getBytes(this.passwordUser);
                    if (passUser.length > 127) {
                        var tempBuf = []; // new byte[127];
                        Array.copy2(passUser, 0, tempBuf, 0, 127);
                        passUser = tempBuf;
                    }
                    hash = this.getHashV5(passUser, userValidationSalt, null);
                    // make U value
                    hash.copyTo(this.userValue, 0);
                    userValidationSalt.copyTo(this.userValue, 32);
                    userKeySalt.copyTo(this.userValue, 40);
                    hash = this.getHashV5(passUser, userKeySalt, null);
                    // make UE value
                    this.encodeKeyDataV5(hash, baseEncryptionKey, true).copyTo(this.userExtendedValue, 0);
                    //#endregion
                    //#region Computing the encryption dictionary’s O(owner password) and OE(owner encryption key) values
                    var password = this.passwordOwner;
                    if (StiString.isNullOrEmpty(this.passwordOwner))
                        password = this.passwordUser;
                    var passOwner = Stimulsoft.System.Text.Encoding.UTF8.getBytes(password);
                    if (passOwner.length > 127) {
                        var tempBuf = []; // new byte[127];
                        Array.copy2(passOwner, 0, tempBuf, 0, 127);
                        passOwner = tempBuf;
                    }
                    hash = this.getHashV5(passOwner, ownerValidationSalt, this.userValue);
                    // make O value
                    hash.copyTo(this.ownerValue, 0);
                    ownerValidationSalt.copyTo(this.ownerValue, 32);
                    ownerKeySalt.copyTo(this.ownerValue, 40);
                    hash = this.getHashV5(passOwner, ownerKeySalt, this.userValue);
                    // make OE value
                    this.encodeKeyDataV5(hash, baseEncryptionKey, true).copyTo(this.ownerExtendedValue, 0);
                    //#endregion
                    //#region Computing the encryption dictionary’s Perms(permissions) value
                    buf = rnd.createNextBytes(16); // Set bytes 12-15 to 4 bytes of random data
                    this.getBytesUInt32(this.securityFlags).copyTo(buf, 0);
                    buf[4] = 0xff;
                    buf[5] = 0xff;
                    buf[6] = 0xff;
                    buf[7] = 0xff;
                    buf[8] = 0x54; // T
                    buf[9] = 0x61; // a
                    buf[10] = 0x64; // d
                    buf[11] = 0x62; // b
                    this.permsValue = this.encodeKeyDataV5(baseEncryptionKey, buf, false);
                    //#endregion
                    //#region Computing an encryption key
                    hash = this.getHashV5(passUser, userKeySalt, null);
                    this.encryptionKey = this.decodeKeyDataV5(hash, this.userExtendedValue, true);
                    //#endregion
                    //#region Verifying key calculation
                    buf = this.decodeKeyDataV5(this.encryptionKey, this.permsValue, false);
                    if ((buf[9] != 0x61) || (buf[10] != 0x64) || (buf[11] != 0x62)) {
                        this.throwEncryptionError(102, "Verifying key calculation failed");
                    }
                    //#endregion
                    return true;
                };
                //#region Encode/Decode V5 methods
                StiPdfSecurity.prototype.encodeKeyDataV5 = function (key, data, cbc) {
                    var result = null;
                    if (cbc) {
                        var iv = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
                        var aesCbc = new Stimulsoft.ExternalLibrary.aesjs.ModeOfOperation.cbc(key, iv);
                        result = aesCbc.encrypt(data);
                    }
                    else {
                        var aesCbc = new Stimulsoft.ExternalLibrary.aesjs.ModeOfOperation.ecb(key);
                        result = aesCbc.encrypt(data);
                    }
                    var result2 = [];
                    for (var index = 0; index < result.length; index++) {
                        result2[index] = result[index];
                    }
                    return result2;
                };
                StiPdfSecurity.prototype.decodeKeyDataV5 = function (key, data, cbc) {
                    // byte[] result = new byte[32]; //maybe need check
                    var result = null;
                    if (cbc) {
                        var iv = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
                        var aesCbc = new Stimulsoft.ExternalLibrary.aesjs.ModeOfOperation.cbc(key, iv);
                        result = aesCbc.decrypt(data);
                    }
                    else {
                        var aesCbc = new Stimulsoft.ExternalLibrary.aesjs.ModeOfOperation.ecb(key);
                        result = aesCbc.decrypt(data);
                    }
                    var result2 = [];
                    for (var index = 0; index < result.length; index++) {
                        result2[index] = result[index];
                    }
                    return result2;
                };
                //#endregion
                //#region Hash calculations
                StiPdfSecurity.prototype.getHashV5 = function (password, salt, ownerkey) {
                    if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit256_r5)
                        return StiPdfSecurity.calculate_hash_r5(password, salt, ownerkey);
                    else
                        return StiPdfSecurity.calculate_hash_r6(password, salt, ownerkey);
                };
                StiPdfSecurity.calculate_hash_r5 = function (password, salt, ownerkey) {
                    var buf = []; // new byte[password.Length + 8 + (ownerkey != null ? 48 : 0)];
                    buf.addRange(password);
                    buf.addRange(salt);
                    if (ownerkey != null)
                        buf.addRange(ownerkey);
                    return Stimulsoft.System.Crypt.SHA2.SHA256(buf);
                };
                StiPdfSecurity.calculate_hash_r6 = function (password, salt, ownerkey) {
                    var data = []; // new byte[(128 + 64 + 48) * 64];
                    var block = []; // new byte[64];
                    var block_size = 32;
                    var data_len = 0;
                    var buf = null;
                    var key = []; // new byte[16];
                    var iv = []; // new byte[16];
                    var sha2 = new Stimulsoft.System.Crypt.SHA2();
                    /* Step 1: calculate initial data block */
                    buf = [];
                    buf.addRange(password);
                    buf.addRange(salt);
                    if (ownerkey != null)
                        buf.addRange(ownerkey);
                    sha2.SHA2_256(buf).copyTo(block, 0);
                    for (var i = 0; i < 64 || i < data[data_len * 64 - 1] + 32; i++) {
                        /* Step 2: repeat password and data block 64 times */
                        buf.clear();
                        buf.addRange(password);
                        for (var k = 0; k < block_size; k++) {
                            buf.add(block[k]);
                        }
                        data_len = password.length + block_size;
                        if (ownerkey != null) {
                            buf.addRange(ownerkey);
                            data_len += 48;
                        }
                        for (var j = 0; j < 64; j++) {
                            buf.copyTo(data, j * data_len);
                        }
                        /* Step 3: encrypt data using data block as key and iv */
                        Array.copy2(block, 0, key, 0, 16);
                        Array.copy2(block, 16, iv, 0, 16);
                        var aes = new Stimulsoft.ExternalLibrary.aesjs.ModeOfOperation.cbc(key, iv);
                        var result = aes.encrypt(data.slice(0, data_len * 64));
                        for (var index = 0; index < result.length; index++) {
                            data[index] = result[index];
                        }
                        /* Step 4: determine SHA-2 hash size for this round */
                        var sum = 0;
                        for (var j = 0; j < 16; j++) {
                            sum += data[j];
                        }
                        /* Step 5: calculate data block for next round */
                        block_size = 32 + (sum % 3) * 16;
                        switch (block_size) {
                            case 32:
                                sha2.SHA2_256(data.slice(0, data_len * 64)).copyTo(block, 0);
                                break;
                            case 48:
                                sha2.SHA2_384(data.slice(0, data_len * 64)).copyTo(block, 0);
                                break;
                            case 64:
                                sha2.SHA2_512(data.slice(0, data_len * 64)).copyTo(block, 0);
                                break;
                        }
                    }
                    var hash = []; // new byte[32];
                    Array.copy2(block, 0, hash, 0, 32);
                    return hash;
                };
                //#endregion
                //#endregion
                //#region EncryptData
                StiPdfSecurity.prototype.encryptData = function (data, currentObjectNumber, currentGenerationNumber) {
                    if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit40 || this.keyLength == Export.StiPdfEncryptionKeyLength.Bit128) {
                        //#region V2 40bit and V3 128bit
                        var objectNumber = currentObjectNumber;
                        var generationNumber = currentGenerationNumber;
                        var hashData = []; // new byte[encryptionKey.Length + 5];
                        this.encryptionKey.copyTo(hashData, 0);
                        this.getBytesUInt32(objectNumber).copyTo(hashData, this.encryptionKeyLength);
                        this.getBytesUint16(generationNumber).copyTo(hashData, this.encryptionKeyLength + 3);
                        var hash = this.computeHashMD5(hashData);
                        if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit40) {
                            hash = hash.slice(0, 10);
                        }
                        data = this.rc4(data, hash);
                        //#endregion
                    }
                    else if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit128_r4) {
                        //#region V4 128bit
                        var objectNumber = currentObjectNumber;
                        var generationNumber = currentGenerationNumber;
                        var hashData = []; // new byte[16 + 5 + 4];
                        this.encryptionKey.copyTo(hashData, 0);
                        this.getBytesUInt32(objectNumber).copyTo(hashData, 16);
                        this.getBytesUint16(generationNumber).copyTo(hashData, 19);
                        hashData[21] = 0x73;
                        hashData[22] = 0x41;
                        hashData[23] = 0x6C;
                        hashData[24] = 0x54;
                        var hash = this.computeHashMD5(hashData);
                        var iv = new Stimulsoft.System.Crypt.SecureRandom().createNextBytes(16);
                        var forEncrypt = [];
                        forEncrypt.addRange(iv);
                        forEncrypt.addRange(data);
                        forEncrypt = new Stimulsoft.ExternalLibrary.aesjs.padding.pkcs7.pad(forEncrypt);
                        var aesCbc = new Stimulsoft.ExternalLibrary.aesjs.ModeOfOperation.cbc(hash, iv);
                        data = aesCbc.encrypt(forEncrypt);
                        //#endregion
                    }
                    else {
                        //#region V5 256bit
                        var iv = new Stimulsoft.System.Crypt.SecureRandom().createNextBytes(16);
                        var forEncrypt = [];
                        forEncrypt.addRange(iv);
                        forEncrypt.addRange(data);
                        forEncrypt = new Stimulsoft.ExternalLibrary.aesjs.padding.pkcs7.pad(forEncrypt);
                        var aesCbc = new Stimulsoft.ExternalLibrary.aesjs.ModeOfOperation.cbc(this.encryptionKey, iv);
                        data = aesCbc.encrypt(forEncrypt);
                        //#endregion
                    }
                    return data;
                };
                //#endregion
                StiPdfSecurity.prototype.throwEncryptionError = function (step, st) {
                    throw new Error(StiString.format("EncryptionError at step {0} : {1}", step, st));
                };
                //#endregion
                //#region RenderEncodeRecord
                StiPdfSecurity.prototype.renderEncodeRecord = function (sw) {
                    var sbOwner = "";
                    var sbUser = "";
                    var sbLength = 32;
                    if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit256_r5 || this.keyLength == Export.StiPdfEncryptionKeyLength.Bit256_r6)
                        sbLength = 48;
                    var index = 0;
                    for (index = 0; index < sbLength; index++) {
                        sbOwner += String.fromCharCode(this.ownerValue[index]);
                        sbUser += String.fromCharCode(this.userValue[index]);
                    }
                    sw.writeLine("/Filter /Standard");
                    if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit128) {
                        sw.writeLine("/CF<</StdCF<</AuthEvent/DocOpen/CFM/V2/Length 16>>>>");
                        sw.writeLine("/StmF /StdCF");
                        sw.writeLine("/StrF /StdCF");
                        sw.writeLine("/R 3");
                        sw.writeLine("/V 2");
                        sw.writeLine("/Length 128");
                    }
                    else if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit128_r4) {
                        sw.writeLine("/CF<</StdCF<</AuthEvent/DocOpen/CFM/AESV2/Length 16>>>>");
                        sw.writeLine("/StmF /StdCF");
                        sw.writeLine("/StrF /StdCF");
                        sw.writeLine("/R 4");
                        sw.writeLine("/V 4");
                        sw.writeLine("/Length 128");
                    }
                    else if (this.keyLength == Export.StiPdfEncryptionKeyLength.Bit256_r5 || this.keyLength == Export.StiPdfEncryptionKeyLength.Bit256_r6) {
                        sw.writeLine("/CF<</StdCF<</AuthEvent/DocOpen/CFM/AESV3/Length 32>>>>");
                        sw.writeLine("/StmF /StdCF");
                        sw.writeLine("/StrF /StdCF");
                        sw.writeLine("/R {0}", this.keyLength == Export.StiPdfEncryptionKeyLength.Bit256_r5 ? 5 : 6);
                        sw.writeLine("/V 5");
                        sw.writeLine("/Length 256");
                        var sbOwnerE = "";
                        var sbUserE = "";
                        for (index = 0; index < 32; index++) {
                            sbOwnerE += String.fromCharCode(this.ownerExtendedValue[index]);
                            sbUserE += String.fromCharCode(this.userExtendedValue[index]);
                        }
                        var sbPerms = "";
                        for (index = 0; index < 16; index++) {
                            sbPerms += String.fromCharCode(this.permsValue[index]);
                        }
                        sw.writeString(StiString.format("/OE ({0})", Export.StiPdfExportService.convertToEscapeSequencePlusTabs(sbOwnerE)), true);
                        sw.writeString(StiString.format("/UE ({0})", Export.StiPdfExportService.convertToEscapeSequencePlusTabs(sbUserE)), true);
                        sw.writeString(StiString.format("/Perms ({0})", Export.StiPdfExportService.convertToEscapeSequencePlusTabs(sbPerms)), true);
                    }
                    else {
                        sw.writeLine("/R 2");
                        sw.writeLine("/V 1");
                        sw.writeLine("/Length 40");
                    }
                    sw.writeString(StiString.format("/O ({0})", Export.StiPdfExportService.convertToEscapeSequencePlusTabs(sbOwner)), true);
                    sw.writeString(StiString.format("/U ({0})", Export.StiPdfExportService.convertToEscapeSequencePlusTabs(sbUser)), true);
                    sw.writeLine("/P {0}", this.securityFlags);
                };
                StiPdfSecurity.prototype.getBytesUInt32 = function (uint) {
                    var buf = [];
                    buf.push(uint & 0xFF);
                    buf.push((uint >> 8) & 0xFF);
                    buf.push((uint >> 16) & 0xFF);
                    buf.push((uint >> 24) & 0xFF);
                    return buf;
                };
                StiPdfSecurity.prototype.getBytesUint16 = function (uint) {
                    var buf = [];
                    buf.push(uint & 0xFF);
                    buf.push((uint >> 8) & 0xFF);
                    return buf;
                };
                StiPdfSecurity.prototype.rc4 = function (data, key) {
                    var s = [];
                    var i = 0;
                    var j = 0;
                    var x;
                    var res = [];
                    var keyLength = key.length;
                    var dataLength = data.length;
                    for (i = 0; i < 256; i++) {
                        s[i] = i;
                    }
                    for (i = 0; i < 256; i++) {
                        j = (j + s[i] + key[i % keyLength]) % 256;
                        x = s[i];
                        s[i] = s[j];
                        s[j] = x;
                    }
                    i = 0;
                    j = 0;
                    for (var y = 0; y < dataLength; y++) {
                        i = (i + 1) % 256;
                        j = (j + s[i]) % 256;
                        x = s[i];
                        s[i] = s[j];
                        s[j] = x;
                        res.push(data[y] ^ s[(s[i] + s[j]) % 256]);
                    }
                    return res;
                };
                StiPdfSecurity.prototype.computeHashMD5 = function (data) {
                    var st = "";
                    for (var index = 0; index < data.length; index++) {
                        st += String.fromCharCode(data[index]);
                    }
                    return Stimulsoft.Base.StiMD5Helper.MD5(st, false);
                };
                StiPdfSecurity.paddingString = [
                    0x28, 0xBF, 0x4E, 0x5E, 0x4E, 0x75, 0x8A, 0x41, 0x64, 0x00, 0x4E, 0x56, 0xFF, 0xFA, 0x01, 0x08,
                    0x2E, 0x2E, 0x00, 0xB6, 0xD0, 0x68, 0x3E, 0x80, 0x2F, 0x0C, 0xA9, 0xFE, 0x64, 0x53, 0x69, 0x7A
                ];
                return StiPdfSecurity;
            }());
            Export.StiPdfSecurity = StiPdfSecurity;
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
            var StiPdfObjInfo = /** @class */ (function () {
                function StiPdfObjInfo() {
                    this.ref = -1;
                    this.info = null;
                }
                Object.defineProperty(StiPdfObjInfo.prototype, "isUsed", {
                    get: function () {
                        return !(this.ref == -1);
                    },
                    enumerable: true,
                    configurable: true
                });
                StiPdfObjInfo.prototype.addRef = function () {
                    this.info.addRef(this);
                };
                StiPdfObjInfo.prototype.toString = function () {
                    if (this.ref == -1)
                        return "-";
                    return StiString.format("ref = {0}", this.ref);
                };
                return StiPdfObjInfo;
            }());
            Export.StiPdfObjInfo = StiPdfObjInfo;
            var StiPdfContentObjInfo = /** @class */ (function (_super) {
                __extends(StiPdfContentObjInfo, _super);
                function StiPdfContentObjInfo() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                return StiPdfContentObjInfo;
            }(StiPdfObjInfo));
            Export.StiPdfContentObjInfo = StiPdfContentObjInfo;
            var StiPdfXObjectObjInfo = /** @class */ (function (_super) {
                __extends(StiPdfXObjectObjInfo, _super);
                function StiPdfXObjectObjInfo() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                return StiPdfXObjectObjInfo;
            }(StiPdfObjInfo));
            Export.StiPdfXObjectObjInfo = StiPdfXObjectObjInfo;
            var StiPdfFontObjInfo = /** @class */ (function (_super) {
                __extends(StiPdfFontObjInfo, _super);
                function StiPdfFontObjInfo() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                return StiPdfFontObjInfo;
            }(StiPdfObjInfo));
            Export.StiPdfFontObjInfo = StiPdfFontObjInfo;
            var StiPdfOutlinesObjInfo = /** @class */ (function (_super) {
                __extends(StiPdfOutlinesObjInfo, _super);
                function StiPdfOutlinesObjInfo() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                return StiPdfOutlinesObjInfo;
            }(StiPdfObjInfo));
            Export.StiPdfOutlinesObjInfo = StiPdfOutlinesObjInfo;
            var StiPdfShadingObjInfo = /** @class */ (function (_super) {
                __extends(StiPdfShadingObjInfo, _super);
                function StiPdfShadingObjInfo() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                return StiPdfShadingObjInfo;
            }(StiPdfObjInfo));
            Export.StiPdfShadingObjInfo = StiPdfShadingObjInfo;
            var StiPdfPatternsObjInfo = /** @class */ (function (_super) {
                __extends(StiPdfPatternsObjInfo, _super);
                function StiPdfPatternsObjInfo() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                return StiPdfPatternsObjInfo;
            }(StiPdfObjInfo));
            Export.StiPdfPatternsObjInfo = StiPdfPatternsObjInfo;
            var StiPdfAnnotObjInfo = /** @class */ (function (_super) {
                __extends(StiPdfAnnotObjInfo, _super);
                function StiPdfAnnotObjInfo() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                return StiPdfAnnotObjInfo;
            }(StiPdfObjInfo));
            Export.StiPdfAnnotObjInfo = StiPdfAnnotObjInfo;
            var StiPdfCheckBoxObjInfo = /** @class */ (function () {
                function StiPdfCheckBoxObjInfo() {
                }
                return StiPdfCheckBoxObjInfo;
            }());
            Export.StiPdfCheckBoxObjInfo = StiPdfCheckBoxObjInfo;
            var StiPdfAcroFormObjInfo = /** @class */ (function (_super) {
                __extends(StiPdfAcroFormObjInfo, _super);
                function StiPdfAcroFormObjInfo() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                return StiPdfAcroFormObjInfo;
            }(StiPdfObjInfo));
            Export.StiPdfAcroFormObjInfo = StiPdfAcroFormObjInfo;
            var StiPdfStructure = /** @class */ (function () {
                function StiPdfStructure() {
                    // Fields
                    this.objectsCounter = 0;
                    this.objects = null; // temp
                    this.objectsCounter = 0;
                    this.objects = []; // temp
                    this.root = this.createObject(true);
                    this.info = this.createObject(true);
                    this.colorSpace = this.createObject(true);
                    this.pages = this.createObject(true);
                    this.structTreeRoot = this.createObject(true);
                    this.optionalContentGroup = this.createObject(true);
                    this.pageList = [];
                    this.xObjectList = [];
                    this.fontList = [];
                    this.linkList = [];
                    this.embeddedFilesList = [];
                }
                // Methods
                StiPdfStructure.prototype.addRef = function (info) {
                    this.objectsCounter++;
                    info.ref = this.objectsCounter;
                };
                StiPdfStructure.prototype.createObject = function (addRef) {
                    if (addRef === void 0) { addRef = false; }
                    var obj = new StiPdfObjInfo();
                    obj.info = this;
                    if (addRef)
                        this.addRef(obj);
                    return obj;
                };
                StiPdfStructure.prototype.createContentObject = function (addRef) {
                    if (addRef === void 0) { addRef = false; }
                    var obj = new StiPdfContentObjInfo();
                    obj.info = this;
                    if (addRef)
                        this.addRef(obj);
                    obj.content = this.createObject(addRef);
                    return obj;
                };
                StiPdfStructure.prototype.createXObject = function (addRef, haveMask) {
                    if (addRef === void 0) { addRef = false; }
                    if (haveMask === void 0) { haveMask = false; }
                    var obj = new StiPdfXObjectObjInfo();
                    obj.info = this;
                    if (addRef)
                        this.addRef(obj);
                    obj.mask = this.createObject(addRef && haveMask);
                    return obj;
                };
                StiPdfStructure.prototype.createFontObject = function (addRef, useUnicodeMode, standardPdfFonts, embeddedFonts, annotFont) {
                    if (addRef === void 0) { addRef = false; }
                    if (useUnicodeMode === void 0) { useUnicodeMode = true; }
                    if (standardPdfFonts === void 0) { standardPdfFonts = false; }
                    if (embeddedFonts === void 0) { embeddedFonts = true; }
                    if (annotFont === void 0) { annotFont = false; }
                    var obj = new StiPdfFontObjInfo();
                    obj.info = this;
                    if (addRef)
                        this.addRef(obj);
                    obj.descendantFont = this.createObject(addRef && useUnicodeMode);
                    obj.toUnicode = this.createObject(addRef && useUnicodeMode);
                    obj.cIDSet = this.createObject(addRef && useUnicodeMode);
                    obj.encoding = this.createObject(addRef && !useUnicodeMode && !annotFont);
                    obj.fontDescriptor = this.createObject(addRef && !standardPdfFonts);
                    obj.fontFile2 = this.createObject(addRef && embeddedFonts);
                    return obj;
                };
                StiPdfStructure.prototype.createOutlinesObject = function (addRef) {
                    if (addRef === void 0) { addRef = false; }
                    var obj = new StiPdfOutlinesObjInfo();
                    obj.info = this;
                    if (addRef)
                        this.addRef(obj);
                    obj.items = [];
                    return obj;
                };
                StiPdfStructure.prototype.createPatternsObject = function (addRef) {
                    if (addRef === void 0) { addRef = false; }
                    var obj = new StiPdfPatternsObjInfo();
                    obj.info = this;
                    obj.resources = this.createObject(addRef);
                    obj.first = this.createObject(addRef);
                    obj.hatchItems = [];
                    obj.shadingItems = [];
                    return obj;
                };
                StiPdfStructure.prototype.createShadingObject = function (addRef) {
                    if (addRef === void 0) { addRef = false; }
                    var obj = new StiPdfShadingObjInfo();
                    obj.info = this;
                    if (addRef)
                        this.addRef(obj);
                    obj.function = this.createObject(addRef);
                    return obj;
                };
                StiPdfStructure.prototype.createAcroFormObject = function (addRef) {
                    if (addRef === void 0) { addRef = false; }
                    var obj = new StiPdfAcroFormObjInfo();
                    obj.info = this;
                    if (addRef)
                        this.addRef(obj);
                    obj.annots = [];
                    obj.checkBoxes = [];
                    obj.unsignedSignatures = [];
                    obj.signatures = [];
                    obj.tooltips = [];
                    obj.annotFontItems = [];
                    return obj;
                };
                StiPdfStructure.prototype.createAnnotObject = function (addRef, createAP, numberAA) {
                    if (addRef === void 0) { addRef = false; }
                    if (createAP === void 0) { createAP = false; }
                    if (numberAA === void 0) { numberAA = 0; }
                    var obj = new StiPdfAnnotObjInfo();
                    obj.info = this;
                    if (addRef)
                        this.addRef(obj);
                    obj.aP = this.createObject(addRef && createAP);
                    obj.aA = [];
                    for (var index = 0; index < numberAA; index++) {
                        obj.aA.add(this.createObject(addRef));
                    }
                    return obj;
                };
                return StiPdfStructure;
            }());
            Export.StiPdfStructure = StiPdfStructure;
        })(Export = Report.Export || (Report.Export = {}));
    })(Report = Stimulsoft.Report || (Stimulsoft.Report = {}));
})(Stimulsoft || (Stimulsoft = {}));
var Stimulsoft;
(function (Stimulsoft) {
    var Report;
    (function (Report) {
        var Export;
        (function (Export) {
            var StiLocalization = Stimulsoft.Base.Localization.StiLocalization;
            var StiRtfData = /** @class */ (function () {
                function StiRtfData() {
                }
                return StiRtfData;
            }());
            var StiRtfStyleInfo = /** @class */ (function () {
                function StiRtfStyleInfo() {
                }
                return StiRtfStyleInfo;
            }());
            var StiRtfExportService = /** @class */ (function (_super) {
                __extends(StiRtfExportService, _super);
                function StiRtfExportService() {
                    var _this = _super !== null && _super.apply(this, arguments) || this;
                    /**/
                    // private sw: StreamWriter = null;
                    _this.colorList = null;
                    _this.fontList = null;
                    _this.styleList = null;
                    _this.unicodeMapArray = null;
                    _this.codePageToFont = null;
                    _this.charsetCount = 0;
                    _this.fontToCodePages = null;
                    _this.baseFontNumber = 0;
                    // private sw2: Stream = null;
                    _this.usePageHeadersAndFooters = false;
                    _this.imageResolution = 0.96; // dpi
                    _this.imageQuality = 0.75;
                    _this.imageFormat = Report.StiExportFormat.Rtf;
                    // private imageCodec: ImageCodecInfo = null;
                    _this.useStyles = false;
                    _this.bookmarkList = null;
                    _this.usedBookmarks = null;
                    return _this;
                    /*private _removeEmptySpaceAtBottom: boolean = StiOptions.Export.RichText.RemoveEmptySpaceAtBottom;
                    get removeEmptySpaceAtBottom(): boolean {
                        return this._removeEmptySpaceAtBottom;
                    }*/
                    /*
                        //conversion of hundredths of inch to twips
                       
                        #endregion*/
                }
                Object.defineProperty(StiRtfExportService.prototype, "defaultExtension", {
                    get: function () {
                        return "rtf";
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiRtfExportService.prototype, "exportFormat", {
                    get: function () {
                        return Report.StiExportFormat.Rtf;
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiRtfExportService.prototype, "groupCategory", {
                    get: function () {
                        return "Word";
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiRtfExportService.prototype, "position", {
                    get: function () {
                        return Export.StiExportPosition.Rtf;
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiRtfExportService.prototype, "exportNameInMenu", {
                    get: function () {
                        return StiLocalization.get("Export", "ExportTypeRtfFile");
                    },
                    enumerable: true,
                    configurable: true
                });
                StiRtfExportService.prototype.getFilter = function () {
                    return StiLocalization.get("FileFilters", "RtfFiles");
                };
                StiRtfExportService.prototype.exportTo = function (report, stream, settings) {
                    // this.exportRtf(report, stream, <StiRtfExportSettings>settings);
                };
                Object.defineProperty(StiRtfExportService.prototype, "multipleFiles", {
                    // private guiMode: StiGuiMode;
                    /*private void form_Complete(IStiFormRunner form, StiShowDialogCompleteEvetArgs e)
            {
                if (e.DialogResult) {
                    if (StiOptions.WCFService.WCFExportDocumentEventIsUsed) {
                        StiOptions.WCFService.InvokeWCFExportDocument(report, StiExportSettingsHelper.GetRtfExportSettings(form, report), "rtf");
                        return;
                    }
            
                    if (string.IsNullOrEmpty(fileName))
                        fileName = base.GetFileName(report, sendEMail);
            
                    if (fileName != null) {
                        StiFileUtils.ProcessReadOnly(fileName);
                        let stream = new FileStream(fileName, FileMode.Create);
            
                        StartProgress(guiMode);
            
                        let settings = new StiRtfExportSettings
                        {
                            PageRange = form["PagesRange"] as StiPagesRange,
                            ExportMode = (StiRtfExportMode) form["ExportMode"],
                            UsePageHeadersAndFooters = (bool) form["UsePageHeadersAndFooters"],
                            ImageQuality = (float) form["ImageQuality"],
                            ImageResolution = (float) form["Resolution"],
                            RemoveEmptySpaceAtBottom = (bool) form["RemoveEmptySpaceAtBottom"]
                        };
            
                        base.StartExport(report, stream, settings, sendEMail, (bool)form["OpenAfterExport"], fileName, guiMode);
                    }
                }
            }*/
                    get: function () {
                        return false;
                    },
                    enumerable: true,
                    configurable: true
                });
                StiRtfExportService.prototype.getColorNumberInt = function (tmpColorList, incomingColor) {
                    if (tmpColorList.length > 0) {
                        for (var index = 0; index < tmpColorList.length; index++) {
                            if (tmpColorList[index].sti.equals(incomingColor)) {
                                // color is already in table, return color number
                                return index;
                            }
                        }
                    }
                    // add color to table, return color number
                    tmpColorList.add(incomingColor);
                    var temp = tmpColorList.length - 1;
                    return temp;
                };
                StiRtfExportService.prototype.getColorNumber = function (tmpColorList, incomingColor) {
                    return this.getColorNumberInt(tmpColorList, incomingColor).toString();
                };
                StiRtfExportService.prototype.getFontNumber2 = function (tmpFontList, incomingFont) {
                    if (tmpFontList.length > 0) {
                        for (var index = 0; index < tmpFontList.length; index++) {
                            var tmpFont = tmpFontList[index];
                            if (tmpFont.name == incomingFont.name) {
                                // font is already in table, return font number
                                return index * (this.charsetCount == 0 ? 1 : this.charsetCount);
                            }
                        }
                    }
                    // add font to table, return font number
                    tmpFontList.add(incomingFont);
                    var temp = tmpFontList.length - 1;
                    return temp * (this.charsetCount == 0 ? 1 : this.charsetCount);
                };
                StiRtfExportService.prototype.getFontNumber3 = function (tmpFontList, incomingFont, charset) {
                    if (tmpFontList.length > 0) {
                        for (var index = 0; index < tmpFontList.length; index++) {
                            var tmpFont = tmpFontList[index];
                            if (tmpFont.name == incomingFont.name) {
                                // font is already in table, return font number
                                return index * (this.charsetCount == 0 ? 1 : this.charsetCount) + this.getCharsetIndex(charset);
                            }
                        }
                    }
                    // add font to table, return font number
                    tmpFontList.add(incomingFont);
                    var temp = tmpFontList.length - 1;
                    return temp * (this.charsetCount == 0 ? 1 : this.charsetCount) + this.getCharsetIndex(charset);
                };
                StiRtfExportService.prototype.getCharsetIndex = function (charset) {
                    var charsetIndex = 0;
                    /*for (let index: number = 0; index < StiEncode.codePagesTableSize; index++) {
                        if (StiEncode.codePagesTable[index, 2] == charset) {
                            charsetIndex = index + 1;
                            break;
                        }
                    }*/
                    if (this.charsetCount == 0) {
                        this.codePageToFont[charsetIndex] = 1;
                        return 0;
                    }
                    return this.codePageToFont[charsetIndex];
                };
                return StiRtfExportService;
            }(Export.StiExportService));
            Export.StiRtfExportService = StiRtfExportService;
        })(Export = Report.Export || (Report.Export = {}));
    })(Report = Stimulsoft.Report || (Stimulsoft.Report = {}));
})(Stimulsoft || (Stimulsoft = {}));