var Stimulsoft;
(function (Stimulsoft) {
    var Report;
    (function (Report) {
        var Engine;
        (function (Engine) {
            var StiString = Stimulsoft.System.StiString;
            var StiSummaryDirection = Stimulsoft.Report.CrossTab.Core.StiSummaryDirection;
            var StiCrossColumn = Stimulsoft.Report.CrossTab.StiCrossColumn;
            var StiCrossSummary = Stimulsoft.Report.CrossTab.StiCrossSummary;
            var StiFilterHelper = Stimulsoft.Report.Components.StiFilterHelper;
            var StiDataBand = Stimulsoft.Report.Components.StiDataBand;
            var StiDockStyle = Stimulsoft.Report.Components.StiDockStyle;
            var RectangleD = Stimulsoft.System.Drawing.Rectangle;
            var StiCrossTab = Stimulsoft.Report.CrossTab.StiCrossTab;
            var StiCrossTabParams = Stimulsoft.Report.CrossTab.StiCrossTabParams;
            var StiCrossTabHelper = Stimulsoft.Report.CrossTab.StiCrossTabHelper;
            var StiContainer = Stimulsoft.Report.Components.StiContainer;
            var StiCrossHorAlignment = Stimulsoft.Report.CrossTab.StiCrossHorAlignment;
            var StiCrossHeaderInteraction = Stimulsoft.Report.Components.StiCrossHeaderInteraction;
            var Hashtable = Stimulsoft.System.Collections.Hashtable;
            var StiCrossTabBuilder = /** @class */ (function (_super) {
                __extends(StiCrossTabBuilder, _super);
                function StiCrossTabBuilder() {
                    
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                // Methods.Helpers
                StiCrossTabBuilder.getCollapsingName = function (header) {
                    return this.getCollapsingName2(header.name, header.headerLevel, header.headerValue);
                };
                StiCrossTabBuilder.getCollapsingName2 = function (componentName, level, value) {
                    return StiString.format("{0}.{1}.{2}", componentName, level, value);
                };
                StiCrossTabBuilder.isCollapsed = function (masterHeader) {
                    return this.isCollapsed2(masterHeader, masterHeader.headerLevel, masterHeader.headerValue);
                };
                StiCrossTabBuilder.isCollapsed2 = function (masterHeader, level, textValue) {
                    // if (StiOptions.Engine.ForceDisableCollapsing) return false;
                    if (masterHeader.interaction == null ||
                        (masterHeader.interaction.sti.is(StiCrossHeaderInteraction) && (!masterHeader.interaction.collapsingEnabled)))
                        return false;
                    var isCollapsed = true;
                    if (masterHeader.report.interactionCollapsingStates == null)
                        return isCollapsed;
                    var value = masterHeader.report.interactionCollapsingStates[this.getCollapsingName2(masterHeader.name, level, textValue)];
                    if (value.sti.is(Boolean))
                        return value.sti.toBoolean();
                    return true;
                };
                StiCrossTabBuilder.setCollapsed = function (masterHeader, isCollapsed) {
                    // if (StiOptions.Engine.ForceDisableCollapsing) return;
                    if (masterHeader.interaction == null || (masterHeader.interaction.sti.is(StiCrossHeaderInteraction) && (!masterHeader.interaction.collapsingEnabled)))
                        return;
                    if (masterHeader.report.interactionCollapsingStates == null)
                        masterHeader.report.interactionCollapsingStates = new Hashtable();
                    masterHeader.report.interactionCollapsingStates[this.getCollapsingName(masterHeader)] = isCollapsed;
                };
                StiCrossTabBuilder.makeHorAlignment = function (masterCrossTab, outContainer, startIndex, parentWidth, pageSegment) {
                    if (masterCrossTab.wrap)
                        return;
                    if (masterCrossTab.horAlignment == StiCrossHorAlignment.Width) {
                        outContainer.left = 0;
                        outContainer.width = parentWidth;
                        StiCrossTabHelper.makeHorAlignmentByWidth(outContainer, startIndex);
                    }
                    else if (masterCrossTab.horAlignment != StiCrossHorAlignment.None) {
                        outContainer.left = 0;
                        outContainer.width = parentWidth * pageSegment;
                        var maxLeft = 0;
                        var maxRight = 0;
                        var REFmaxLeft = { ref: maxLeft };
                        var REFmaxRight = { ref: maxRight };
                        StiCrossTabHelper.calculateMaxAndMin(outContainer, REFmaxLeft, REFmaxRight, startIndex);
                        maxLeft = REFmaxLeft.ref;
                        maxRight = REFmaxRight.ref;
                        for (var index = startIndex; index < outContainer.components.count; index++) {
                            var comp = outContainer.components.getByIndex(index);
                            if (masterCrossTab.horAlignment == StiCrossHorAlignment.Left) {
                                comp.left -= maxLeft;
                            }
                            else if (masterCrossTab.horAlignment == StiCrossHorAlignment.Right) {
                                comp.left += outContainer.width - maxRight;
                            }
                            else if (masterCrossTab.horAlignment == StiCrossHorAlignment.Center) {
                                var newLeft = (outContainer.width - (maxRight - maxLeft)) / 2;
                                comp.left -= (maxLeft - newLeft);
                            }
                        }
                    }
                };
                StiCrossTabBuilder.prototype.renderCrossTabOnPage = function (pars, master, destination, rect, endCol, endRow) {
                    this.renderCrossTabSegment(pars, master, destination, rect, endCol, endRow);
                    this.makeHorAlignment(master, destination, 0, pars.destinationContainer != null ? pars.destinationContainer.width : master.parent.width, 1);
                    this.finalizeCross(destination);
                };
                StiCrossTabBuilder.prototype.makeHorAlignment = function (master, destination, startIndex, parentWidth, segmentPerWidth) {
                    if (master.wrap)
                        return;
                    if (master.horAlignment == StiCrossHorAlignment.Width) {
                        destination.left = 0;
                        destination.width = parentWidth;
                        StiCrossTabHelper.makeHorAlignmentByWidth(destination, startIndex);
                    }
                    else if (master.horAlignment != StiCrossHorAlignment.None) {
                        destination.left = 0;
                        destination.width = parentWidth * (segmentPerWidth > 1 ? segmentPerWidth : 1);
                        var maxLeft = { ref: 0 };
                        var maxRight = { ref: 0 };
                        StiCrossTabHelper.calculateMaxAndMin(destination, maxLeft, maxRight, startIndex);
                        for (var index = startIndex; index < destination.components.count; index++) {
                            var comp = destination.components.getByIndex(index);
                            switch (master.horAlignment) {
                                case StiCrossHorAlignment.Left:
                                    comp.left -= maxLeft.ref;
                                    break;
                                case StiCrossHorAlignment.Right:
                                    comp.left += destination.width - maxRight.ref;
                                    break;
                                case StiCrossHorAlignment.Center:
                                    var newLeft = (destination.width - (maxRight.ref - maxLeft.ref)) / 2;
                                    comp.left -= (maxLeft.ref - newLeft);
                                    break;
                            }
                        }
                    }
                };
                StiCrossTabBuilder.prototype.finalizeCross = function (renderedComponent) {
                    renderedComponent.canGrow = false;
                    renderedComponent.canShrink = true;
                    var size = renderedComponent.getActualSize();
                    renderedComponent.width = size.width;
                    renderedComponent.height = size.height;
                    renderedComponent.canGrow = true;
                };
                StiCrossTabBuilder.prototype.renderCrossTabSegment = function (pars, master, destination, rect, endCol, endRow) {
                    var cross = master.crossTabInfo.cross;
                    var ref = { ref: rect };
                    this.renderRowHeaders(pars, master, destination, ref);
                    this.renderColHeaders(pars, master, destination, ref);
                    rect = ref.ref;
                    endRow.ref = StiCrossTabHelper.getEndRow(master, pars.startRow, rect);
                    endCol.ref = StiCrossTabHelper.getEndCol(master, pars.startColumn, rect);
                    endRow.ref = StiCrossTabHelper.checkMergedRowCells(master, pars.startRow, endRow.ref, pars.startColumn, endCol.ref);
                    if (pars.startRow < endRow.ref)
                        StiCrossTabHelper.renderCells(master, destination, pars.startColumn, pars.startRow, endCol.ref, endRow.ref, rect);
                    pars.renderingIsFinished = (endCol.ref == cross.colCount) && (endRow.ref == cross.rowCount);
                    pars.startColumn = endCol.ref;
                    if (endCol.ref == cross.colCount) {
                        pars.startColumn = 0;
                        pars.startRow = endRow.ref;
                    }
                };
                StiCrossTabBuilder.prototype.renderColHeaders = function (pars, master, destination, rect, measure, skipStartRowCheck) {
                    if (measure === void 0) { measure = false; }
                    if (skipStartRowCheck === void 0) { skipStartRowCheck = false; }
                    if (pars.startRow == 0 && !skipStartRowCheck)
                        return 0;
                    if (!measure) {
                        var measureRect = rect.ref.clone();
                        measureRect.height = 100000;
                        var height = this.renderColHeaders(pars, master, destination, { ref: measureRect }, true, skipStartRowCheck);
                        if (height > rect.ref.height)
                            return 0;
                    }
                    var cross = master.crossTabInfo.cross;
                    var endCol = this.getEndColumn(pars, rect.ref, cross, master);
                    if (!measure) {
                        var rectMeasure = rect.ref.clone();
                        if (this.renderColHeaders(pars, master, destination, { ref: rectMeasure }, true) > rect.ref.height)
                            return 0;
                    }
                    var totalHeight = 0;
                    var index = 0;
                    if (cross.isTopCrossTitleVisible) {
                        if (cross.isCrossTitlePrintOnAllPages) {
                            if (!measure)
                                StiCrossTabHelper.renderCells(master, destination, pars.startColumn, 0, endCol, 1, rect.ref);
                            rect.ref.y += cross.heights[0];
                            rect.ref.height -= cross.heights[0];
                            totalHeight += cross.heights[0];
                        }
                        index++;
                    }
                    if (StiCrossTabHelper.isColFieldsEmpty(master))
                        return totalHeight;
                    if (!measure && this.allColFieldsPresentOnAllPages(cross)) // Render headers as single block to merge column header with size more then 1
                        StiCrossTabHelper.renderCells(master, destination, pars.startColumn, index, endCol, index + cross.colFields.count, rect.ref);
                    for (var _i = 0, _a = cross.colFields.toCast(); _i < _a.length; _i++) {
                        var field = _a[_i];
                        if (field.printOnAllPages) {
                            if (!measure && !this.allColFieldsPresentOnAllPages(cross))
                                StiCrossTabHelper.renderCells(master, destination, pars.startColumn, index, endCol, index + 1, rect.ref);
                            var height = cross.heights.length > index ? cross.heights[index] : 0;
                            rect.ref.y += height;
                            rect.ref.height -= height;
                            totalHeight += height;
                        }
                        index++;
                    }
                    return totalHeight;
                };
                StiCrossTabBuilder.prototype.allColFieldsPresentOnAllPages = function (cross) {
                    return cross.colFields.toList().count2(function (c) { return c.printOnAllPages; }) == cross.colFields.count;
                };
                StiCrossTabBuilder.prototype.getEndColumn = function (pars, rect, cross, master) {
                    var width = rect.width;
                    var index = pars.startColumn;
                    while (index < cross.colCount) {
                        width -= cross.widths[index];
                        if (width < 0 && master.horAlignment != StiCrossHorAlignment.Width)
                            break;
                        index++;
                    }
                    if (index == pars.startColumn && (index + 1) <= cross.colCount)
                        index++;
                    return index;
                };
                StiCrossTabBuilder.prototype.getEndRow = function (pars, rect, cross) {
                    var height = rect.height;
                    var index = pars.startRow;
                    while (index < cross.rowCount) {
                        height -= cross.heights[index];
                        if (height < 0)
                            break;
                        index++;
                    }
                    if (index == pars.startRow && (index + 1) <= cross.rowCount)
                        index++;
                    return index;
                };
                StiCrossTabBuilder.prototype.renderRowHeaders = function (pars, master, destination, rect, measure) {
                    if (measure === void 0) { measure = false; }
                    var cross = master.crossTabInfo.cross;
                    if (!master.rightToLeft && pars.startColumn == 0)
                        return 0;
                    if (master.rightToLeft && !measure) {
                        var endCol = StiCrossTabHelper.getEndCol(master, pars.startColumn, rect);
                        if (endCol == cross.cells.length) {
                            if (master.rightToLeft && rect.ref.width != 100000 - pars.shiftX - destination.left) {
                                var colsWidth = 0;
                                for (var i = pars.startColumn; i < endCol; i++) {
                                    colsWidth += cross.widths[i];
                                }
                                rect.ref.x += (rect.ref.width - colsWidth);
                            }
                            return 0;
                        }
                    }
                    var headersWidth = 0;
                    if (!measure) {
                        var measureRect = rect.clone();
                        measureRect.width = 100000;
                        var mrf = { ref: measureRect };
                        headersWidth = this.renderRowHeaders(pars, master, destination, mrf, true);
                        measureRect = mrf.ref;
                        if (headersWidth > rect.ref.width)
                            return 0;
                        if (master.rightToLeft) {
                            measureRect = rect.ref.clone();
                            measureRect.width -= headersWidth;
                            var endCol = StiCrossTabHelper.getEndCol(master, pars.startColumn, measureRect);
                            var nonHeaderWidth = 0;
                            for (var i = pars.startColumn; i < endCol; i++) {
                                nonHeaderWidth += cross.widths[i];
                            }
                            if (rect.ref.width != 100000)
                                rect.ref.x += rect.ref.width - (nonHeaderWidth + headersWidth);
                            rect.ref.width = nonHeaderWidth + headersWidth;
                        }
                    }
                    var resHeight = rect.ref.height;
                    var resY = rect.ref.y;
                    var resX = rect.ref.x;
                    this.renderCorner(pars, master, destination, rect, cross, measure);
                    if (!measure) {
                        var rectMeasure = rect.ref.clone();
                        if (this.renderRowHeaders(pars, master, destination, { ref: rectMeasure }, true) > rect.ref.width)
                            return 0;
                    }
                    var totalWidth = 0;
                    var endRow = this.getEndRow(pars, rect.ref, cross);
                    var index = 0;
                    if (cross.isLeftCrossTitleVisible || (cross.isTopCrossTitleVisible && cross.isColsEmpty)) {
                        if (cross.isCrossTitlePrintOnAllPages) {
                            if (!measure)
                                StiCrossTabHelper.renderCells(master, destination, 0, pars.startRow, 1, endRow, rect.ref);
                            rect.ref.X += cross.widths[0];
                            rect.ref.width -= cross.widths[0];
                            totalWidth += cross.widths[0];
                        }
                        index++;
                    }
                    if (StiCrossTabHelper.isRowFieldsEmpty(master))
                        return totalWidth;
                    var inc = 1;
                    if (master.rightToLeft) {
                        index = cross.cells.length - 1 - index;
                        inc = -1;
                    }
                    var startIndex = index;
                    var sumWidth = 0;
                    for (var _i = 0, _a = cross.rowFields.toCast(); _i < _a.length; _i++) {
                        var field = _a[_i];
                        var width = cross.widths.length > index ? cross.widths[index] : 0;
                        if (field.printOnAllPages) {
                            sumWidth += width;
                            totalWidth += width;
                        }
                        if ((!field.printOnAllPages || field == cross.rowFields.getByIndex(cross.rowFields.count - 1)) && sumWidth > 0) {
                            if (master.rightToLeft)
                                rect.ref.x = resX + rect.ref.width - sumWidth;
                            if (!measure)
                                StiCrossTabHelper.renderCells(master, destination, startIndex, pars.startRow, index + 1, endRow, rect.ref);
                            if (!master.rightToLeft)
                                rect.ref.X += sumWidth;
                            rect.ref.width -= sumWidth;
                            sumWidth = 0;
                            startIndex = index + inc;
                        }
                        if (!master.rightToLeft)
                            index++;
                        else
                            startIndex--;
                    }
                    if (master.rightToLeft)
                        rect.ref.x = resX;
                    rect.ref.y = resY;
                    rect.ref.height = resHeight;
                    return totalWidth;
                };
                StiCrossTabBuilder.prototype.renderCorner = function (pars, master, destination, rect, cross, measure) {
                    if (measure === void 0) { measure = false; }
                    if (pars.startRow == 0 || StiCrossTabHelper.isColFieldsEmpty(master))
                        return 0;
                    if (!measure) {
                        var rectMeasure = rect.ref.clone();
                        if (this.renderCorner(pars, master, destination, { ref: rectMeasure }, cross, true) > rect.ref.height)
                            return 0;
                    }
                    var totalHeight = 0;
                    var index = 0;
                    var rowCount = cross.rowFields.toList().count2(function (r) { return r.printOnAllPages; });
                    if (cross.isTopCrossTitleVisible) {
                        if (cross.isCrossTitlePrintOnAllPages) {
                            if (!measure)
                                StiCrossTabHelper.renderCells(master, destination, 0, 0, rowCount, 1, rect.ref);
                            rect.ref.y += cross.heights[0];
                            rect.ref.height -= cross.heights[0];
                            totalHeight += cross.heights[0];
                        }
                        index++;
                    }
                    if (!measure && this.allColFieldsPresentOnAllPages(cross)) // Render headers as single block to merge column header with size more then 1
                        StiCrossTabHelper.renderCells(master, destination, 0, index, rowCount, index + cross.colFields.count, rect.ref);
                    for (var _i = 0, _a = cross.colFields.toCast(); _i < _a.length; _i++) {
                        var field = _a[_i];
                        if (field.printOnAllPages) {
                            if (!measure && !this.allColFieldsPresentOnAllPages(cross))
                                StiCrossTabHelper.renderCells(master, destination, 0, index, rowCount, index + 1, rect.ref);
                            var height = cross.heights.length > index ? cross.heights[index] : 0;
                            rect.ref.y += height;
                            rect.ref.height -= height;
                            totalHeight += height;
                        }
                        index++;
                    }
                    return totalHeight;
                };
                StiCrossTabBuilder.prototype.renderCrossTabOnDataBand = function (pars, masterCrossTab, renderedComponent) {
                    var rect = pars.destinationRectangle.clone();
                    rect.x = 0;
                    rect.y = 0;
                    rect.width = masterCrossTab.parent.width - rect.left;
                    rect.height = Number.MAX_VALUE;
                    var endRow = pars.startRow;
                    var endCol = pars.startColumn;
                    // Placed on DataBand
                    pars.startColumn = 0;
                    var page = masterCrossTab.page;
                    var pageWidthStep = page.pageWidth - page.margins.left - page.margins.right;
                    var pageWidth = pageWidthStep;
                    if (!page.unlimitedBreakable) {
                        rect.width = 1000000000;
                        pageWidth = 1000000000;
                        pageWidthStep = 1000000000;
                    }
                    var startIndex = renderedComponent.components.count;
                    var crossTitleVisible = (masterCrossTab.crossTabInfo.cross.leftCrossTitle != null && masterCrossTab.crossTabInfo.cross.leftCrossTitle.enabled) &&
                        (masterCrossTab.crossTabInfo.cross.rightCrossTitle != null && masterCrossTab.crossTabInfo.cross.rightCrossTitle.enabled);
                    var crossTitlePrintOnAllPages = (masterCrossTab.crossTabInfo.cross.leftCrossTitle != null && masterCrossTab.crossTabInfo.cross.leftCrossTitle.printOnAllPages) &&
                        (masterCrossTab.crossTabInfo.cross.rightCrossTitle != null && masterCrossTab.crossTabInfo.cross.rightCrossTitle.printOnAllPages);
                    // Fix 2015- 05 - 21, now showing headers of cros- tab on every page in minimal configuration of "cross-tab on databand"
                    if (!crossTitleVisible)
                        crossTitleVisible = (masterCrossTab.crossTabInfo.cross.rowTitleFields != null &&
                            masterCrossTab.crossTabInfo.cross.rowTitleFields.count > 0 &&
                            masterCrossTab.crossTabInfo.cross.rowTitleFields.toList().any(function (item) { return item.enabled; }));
                    if (!crossTitlePrintOnAllPages)
                        crossTitlePrintOnAllPages = (masterCrossTab.crossTabInfo.cross.rowTitleFields != null &&
                            masterCrossTab.crossTabInfo.cross.rowTitleFields.count > 0 &&
                            masterCrossTab.crossTabInfo.cross.summaryCrossTitle != null &&
                            masterCrossTab.crossTabInfo.cross.summaryCrossTitle.printOnAllPages);
                    var startRowIndex = 0;
                    var pageNumber = 0;
                    // run on rows
                    while (startRowIndex < masterCrossTab.crossTabInfo.cross.rowCount) {
                        // control for data placement
                        var rectForTab = new RectangleD();
                        if (masterCrossTab.printTitleOnAllPages) {
                            if (startRowIndex == 0) {
                                rectForTab.height = masterCrossTab.report.engine.freeSpace;
                                if (page.unlimitedHeight && !page.unlimitedBreakable)
                                    rectForTab.height = 1000000000;
                                rectForTab.height -= masterCrossTab.top;
                            }
                            else
                                rectForTab.height = masterCrossTab.report.engine.staticBands.reservedFreeSpace;
                        }
                        else
                            rectForTab.height = 1000000000;
                        // run on columns
                        while (pars.startColumn < masterCrossTab.crossTabInfo.cross.colCount) {
                            var offsetOnY = 0;
                            var offsetOnX = 0;
                            rectForTab.width = pageWidthStep;
                            // Row Headers
                            var widthRowHeader = 0;
                            var countActualHeaderRowCount = this.getActualHeaderRowCount(masterCrossTab);
                            if (masterCrossTab.wrap) {
                                if (masterCrossTab.rightToLeft) {
                                    for (var index = masterCrossTab.crossTabInfo.cross.widths.length - 1; index > masterCrossTab.crossTabInfo.cross.widths.length - countActualHeaderRowCount - 1; index--) {
                                        widthRowHeader += masterCrossTab.crossTabInfo.cross.widths[index];
                                    }
                                    rectForTab.width -= widthRowHeader;
                                }
                            }
                            endCol = StiCrossTabHelper.getEndCol(masterCrossTab, pars.startColumn, rectForTab);
                            // Column Headers
                            if (startRowIndex != 0 && masterCrossTab.printTitleOnAllPages) {
                                // Draw Headers
                                if (crossTitleVisible && crossTitlePrintOnAllPages) {
                                    // fix: if header is first on the band, then move it to duplicate
                                    if (startRowIndex == 1)
                                        rect.y += masterCrossTab.crossTabInfo.cross.heights[0] * 0.7;
                                    StiCrossTabHelper.renderCells(masterCrossTab, renderedComponent, pars.startColumn, 0, endCol, 1, rect);
                                    rect.y += masterCrossTab.crossTabInfo.cross.heights[0];
                                    offsetOnY += masterCrossTab.crossTabInfo.cross.heights[0];
                                    rectForTab.height -= masterCrossTab.crossTabInfo.cross.heights[0];
                                }
                                // Draw Headers Colunms
                                var rowIndexEnd = this.getActualHeaderRowCount(masterCrossTab);
                                // if this header is first on the band
                                if (rowIndexEnd != 0 && startRowIndex != 1) {
                                    // if this header is visible
                                    if (crossTitleVisible) {
                                        // if header is printing on every page
                                        if (crossTitlePrintOnAllPages) {
                                            StiCrossTabHelper.renderCells(masterCrossTab, renderedComponent, pars.startColumn, 1, endCol, rowIndexEnd + 1, rect);
                                            for (var i = 1; i <= rowIndexEnd; i++) {
                                                rect.y += masterCrossTab.crossTabInfo.cross.heights[i];
                                                offsetOnY += masterCrossTab.crossTabInfo.cross.heights[i];
                                                rectForTab.height -= masterCrossTab.crossTabInfo.cross.heights[i];
                                            }
                                        }
                                    }
                                    // if this header is invisible
                                    else {
                                        StiCrossTabHelper.renderCells(masterCrossTab, renderedComponent, pars.startColumn, 1, endCol, rowIndexEnd + 1, rect);
                                        for (var i = 1; i <= rowIndexEnd; i++) {
                                            rect.y += masterCrossTab.crossTabInfo.cross.heights[i];
                                            offsetOnY += masterCrossTab.crossTabInfo.cross.heights[i];
                                            rectForTab.height -= masterCrossTab.crossTabInfo.cross.heights[i];
                                        }
                                    }
                                }
                                endCol = StiCrossTabHelper.getEndCol(masterCrossTab, pars.startColumn, rectForTab);
                            }
                            endRow = StiCrossTabHelper.getEndRow(masterCrossTab, startRowIndex, rectForTab);
                            StiCrossTabHelper.renderCells(masterCrossTab, renderedComponent, pars.startColumn, startRowIndex, endCol, endRow, rect);
                            // Wrap mode
                            if (masterCrossTab.wrap) {
                                // RightToLeft
                                if (masterCrossTab.rightToLeft) {
                                    if (endCol < masterCrossTab.crossTabInfo.cross.colCount - 1) {
                                        var _width = 0;
                                        for (var index = pars.startColumn; index < endCol; index++) {
                                            _width += masterCrossTab.crossTabInfo.cross.widths[index];
                                        }
                                        rect.x += _width;
                                        StiCrossTabHelper.renderCells(masterCrossTab, renderedComponent, masterCrossTab.crossTabInfo.cross.widths.length - countActualHeaderRowCount, startRowIndex, masterCrossTab.crossTabInfo.cross.widths.length, endRow, rect);
                                        rect.x -= _width;
                                    }
                                }
                                var sizeCrossTab = StiCrossTabHelper.getCellsRect(masterCrossTab, pars.startColumn, pars.startRow, endCol, endRow);
                                if ((rectForTab.height - sizeCrossTab.height) < (sizeCrossTab.height + masterCrossTab.wrapGap)) {
                                    pageNumber++;
                                    rect.y = masterCrossTab.page.height * pageNumber;
                                    rect.x = 0;
                                    if (startRowIndex == 0)
                                        rectForTab.height = masterCrossTab.report.engine.freeSpace - masterCrossTab.top;
                                    else
                                        rectForTab.height = masterCrossTab.report.engine.staticBands.reservedFreeSpace;
                                }
                                else {
                                    rect.y += (sizeCrossTab.height + masterCrossTab.wrapGap);
                                    rectForTab.height -= (sizeCrossTab.height + masterCrossTab.wrapGap);
                                    rect.x = 0;
                                }
                                pars.startColumn = endCol;
                            }
                            else {
                                rect.x += pageWidth - offsetOnX;
                                rect.width = pageWidthStep;
                                pars.startColumn = endCol;
                                if (startRowIndex != 0) {
                                    rect.y -= offsetOnY;
                                    rectForTab.height += offsetOnY;
                                }
                            }
                        }
                        if (!masterCrossTab.wrap) {
                            rect.y += rectForTab.height;
                            rect.x = 0;
                        }
                        startRowIndex = endRow;
                        pars.startColumn = 0;
                    }
                    var pageSegment = renderedComponent.containerInfo.setSegmentPerWidth = StiCrossTabHelper.getPageSegmentsRequired(masterCrossTab);
                    StiCrossTabBuilder.makeHorAlignment(masterCrossTab, renderedComponent, startIndex, masterCrossTab.parent.width, pageSegment);
                    if (!page.unlimitedBreakable) {
                        // Increase SegmentPerWidth
                        var maxRight2 = 0;
                        for (var compIndex = startIndex; compIndex < renderedComponent.components.count; compIndex++) {
                            var comp = renderedComponent.components.getByIndex(compIndex);
                            maxRight2 = Math.max(comp.right, maxRight2);
                        }
                        var pageWidth2 = page.width;
                        var pageSegmentPerWidth = page.segmentPerWidth;
                        while (pageWidth2 < maxRight2) {
                            pageSegmentPerWidth++;
                            renderedComponent.containerInfo.setSegmentPerWidth = pageSegmentPerWidth;
                            pageWidth2 += page.width;
                        }
                    }
                    return renderedComponent;
                };
                StiCrossTabBuilder.prototype.renderCrossTab = function (pars, masterCrossTab) {
                    return __awaiter(this, void 0, void 0, function () {
                        var placedOnBand, renderedComponent, rect, endRow, endCol, cont, sizeRenderTab, crossTitleVisible, crossTitlePrintOnAllPages, stX, stY, resX, resY, rowIndex, colWidth, colIndex, ht, endRW, rwIndex, rowIndex, rowIndexEnd, rectTitle, wd, endColumn, clIndex, colIndex, colIndexEnd, flag, size, indexLine, sumHeight;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0:
                                    placedOnBand = Engine.StiSubReportsHelper.getParentBand(masterCrossTab) != null;
                                    renderedComponent = pars.destinationContainer;
                                    if (!(renderedComponent == null)) return [3 /*break*/, 2];
                                    return [4 /*yield*/, _super.prototype.internalRender.call(this, masterCrossTab)];
                                case 1:
                                    renderedComponent = (_a.sent()).sti.as(StiContainer);
                                    renderedComponent.components.clear();
                                    _a.label = 2;
                                case 2:
                                    renderedComponent.dockStyle = StiDockStyle.None;
                                    if (!(masterCrossTab.page.unlimitedHeight && !masterCrossTab.page.unlimitedBreakable)) {
                                        renderedComponent.canBreak = true;
                                    }
                                    if (!pars.allowRendering)
                                        return [2 /*return*/, renderedComponent];
                                    if ((masterCrossTab.dataSource == null || masterCrossTab.dataSource.isEmpty) && (!masterCrossTab.printIfEmpty)) {
                                        pars.renderingIsFinished = true;
                                        return [2 /*return*/, renderedComponent];
                                    }
                                    if (placedOnBand)
                                        return [2 /*return*/, this.renderCrossTabOnDataBand(pars, masterCrossTab, renderedComponent)];
                                    rect = pars.destinationRectangle.clone();
                                    if (masterCrossTab.page.unlimitedHeight)
                                        rect.height = 100000000;
                                    rect.x = 0;
                                    rect.y = 0;
                                    endRow = pars.startRow;
                                    endCol = pars.startColumn;
                                    // Wrap Cross-Tab
                                    if (masterCrossTab.wrap) {
                                        cont = renderedComponent.sti.as(StiContainer);
                                        while (pars.startColumn < masterCrossTab.crossTabInfo.cross.colCount) {
                                            endRow = StiCrossTabHelper.getEndRow(masterCrossTab, pars.startRow, rect);
                                            endCol = StiCrossTabHelper.getEndCol(masterCrossTab, pars.startColumn, rect);
                                            StiCrossTabHelper.renderCells(masterCrossTab, renderedComponent, pars.startColumn, pars.startRow, endCol, endRow, rect);
                                            sizeRenderTab = StiCrossTabHelper.getCellsRect(masterCrossTab, pars.startColumn, pars.startRow, endCol, endRow);
                                            if (endCol == masterCrossTab.crossTabInfo.cross.colCount && endRow == masterCrossTab.crossTabInfo.cross.rowCount) {
                                                pars.renderingIsFinished = true;
                                                return [2 /*return*/, renderedComponent];
                                            }
                                            // change StartColumn and StartRow
                                            if (endCol == masterCrossTab.crossTabInfo.cross.colCount) {
                                                pars.startRow = endRow;
                                                pars.startColumn = 0;
                                            }
                                            else {
                                                pars.startColumn = endCol;
                                            }
                                            if ((rect.height - masterCrossTab.wrapGap - sizeRenderTab.height) > sizeRenderTab.height) {
                                                rect.y = sizeRenderTab.height + masterCrossTab.wrapGap;
                                                rect.height -= sizeRenderTab.height + masterCrossTab.wrapGap;
                                            }
                                            else {
                                                pars.renderingIsFinished = false;
                                                return [2 /*return*/, renderedComponent];
                                            }
                                        }
                                        pars.renderingIsFinished = true;
                                        return [2 /*return*/, renderedComponent];
                                    }
                                    rect.x = 0;
                                    rect.y = 0;
                                    endCol = StiCrossTabHelper.getEndCol(masterCrossTab, pars.startColumn, rect);
                                    endRow = StiCrossTabHelper.getEndRow(masterCrossTab, pars.startRow, rect);
                                    crossTitleVisible = (masterCrossTab.crossTabInfo.cross.leftCrossTitle != null && masterCrossTab.crossTabInfo.cross.leftCrossTitle.enabled) &&
                                        (masterCrossTab.crossTabInfo.cross.rightCrossTitle != null && masterCrossTab.crossTabInfo.cross.rightCrossTitle.enabled);
                                    crossTitlePrintOnAllPages = (masterCrossTab.crossTabInfo.cross.leftCrossTitle != null && masterCrossTab.crossTabInfo.cross.leftCrossTitle.printOnAllPages) &&
                                        (masterCrossTab.crossTabInfo.cross.rightCrossTitle != null && masterCrossTab.crossTabInfo.cross.rightCrossTitle.printOnAllPages);
                                    stX = rect.x;
                                    stY = rect.y;
                                    resX = rect.x;
                                    resY = rect.y;
                                    if (pars.startColumn != 0) {
                                        for (rowIndex = 0; rowIndex < masterCrossTab.crossTabInfo.cross.rowFields.count; rowIndex++) {
                                            if (masterCrossTab.crossTabInfo.cross.rowFields.getByIndex(rowIndex).printOnAllPages && (!masterCrossTab.rightToLeft)) {
                                                colWidth = masterCrossTab.crossTabInfo.cross.widths[rowIndex];
                                                stX += colWidth;
                                                rect.width -= colWidth;
                                            }
                                        }
                                    }
                                    if (pars.startRow != 0) {
                                        for (colIndex = 0; colIndex < masterCrossTab.crossTabInfo.cross.colFields.count; colIndex++) {
                                            if (masterCrossTab.crossTabInfo.cross.colFields.getByIndex(colIndex).printOnAllPages) {
                                                stY += masterCrossTab.crossTabInfo.cross.heights[colIndex];
                                                rect.height -= masterCrossTab.crossTabInfo.cross.heights[colIndex];
                                            }
                                        }
                                    }
                                    if (crossTitleVisible && crossTitlePrintOnAllPages && pars.startRow != 0) {
                                        stY += masterCrossTab.crossTabInfo.cross.heights[masterCrossTab.crossTabInfo.cross.colFields.count];
                                        rect.height -= masterCrossTab.crossTabInfo.cross.heights[masterCrossTab.crossTabInfo.cross.colFields.count];
                                    }
                                    // Row Headers
                                    if (pars.startColumn != 0 && (!StiCrossTabHelper.isRowFieldsEmpty(masterCrossTab))) {
                                        rect.x = resX;
                                        rect.y = stY;
                                        ht = rect.height;
                                        endRW = pars.startRow;
                                        for (rwIndex = pars.startRow; rwIndex < endRow; rwIndex++) {
                                            ht -= masterCrossTab.crossTabInfo.cross.heights[rwIndex];
                                            if (ht < 0)
                                                break;
                                            endRW++;
                                        }
                                        endRow = endRW;
                                        rowIndex = 0;
                                        while (rowIndex < masterCrossTab.crossTabInfo.cross.rowFields.count) {
                                            rowIndexEnd = rowIndex;
                                            while (rowIndexEnd < masterCrossTab.crossTabInfo.cross.rowFields.count &&
                                                masterCrossTab.crossTabInfo.cross.rowFields.getByIndex(rowIndexEnd).printOnAllPages && (!masterCrossTab.rightToLeft)) {
                                                rowIndexEnd++;
                                            }
                                            if (rowIndex != rowIndexEnd) {
                                                if (pars.startRow > 0) {
                                                    rectTitle = rect.clone();
                                                    rectTitle.y = 0;
                                                    // fix at 2015.06.15:
                                                    rectTitle.height -= rect.y;
                                                    StiCrossTabHelper.renderCells(masterCrossTab, renderedComponent, 0, 0, rowIndexEnd, masterCrossTab.crossTabInfo.cross.getCorrectedColumnsHeaderHeight(), rectTitle);
                                                }
                                                StiCrossTabHelper.renderCells(masterCrossTab, renderedComponent, rowIndex, pars.startRow, rowIndexEnd, endRow, rect);
                                                rect.x += masterCrossTab.crossTabInfo.cross.widths[rowIndex];
                                            }
                                            rowIndex = rowIndexEnd + 1;
                                        }
                                    }
                                    // Col Headers
                                    if (pars.startRow != 0) {
                                        rect.x = stX;
                                        rect.y = resY;
                                        wd = rect.width;
                                        endColumn = pars.startColumn;
                                        for (clIndex = pars.startColumn; clIndex < endCol; clIndex++) {
                                            wd -= masterCrossTab.crossTabInfo.cross.widths[clIndex];
                                            if (wd < 0)
                                                break;
                                            endColumn++;
                                        }
                                        endCol = endColumn;
                                        // Render CrossTitles on All Pages
                                        if (crossTitleVisible && crossTitlePrintOnAllPages) // && (!masterCrossTab.RightToLeft))
                                         {
                                            StiCrossTabHelper.renderCells(masterCrossTab, renderedComponent.sti.as(StiContainer), pars.startColumn, 0, endCol, 1, rect);
                                            rect.y += masterCrossTab.crossTabInfo.cross.heights[0];
                                        }
                                        colIndex = 0;
                                        while (colIndex < masterCrossTab.crossTabInfo.cross.colFields.count) {
                                            colIndexEnd = colIndex;
                                            while (colIndexEnd < masterCrossTab.crossTabInfo.cross.colFields.count &&
                                                masterCrossTab.crossTabInfo.cross.colFields.getByIndex(colIndexEnd).printOnAllPages) // && (!masterCrossTab.RightToLeft))
                                             {
                                                colIndexEnd++;
                                            }
                                            if (colIndex != colIndexEnd) {
                                                if (crossTitleVisible) {
                                                    StiCrossTabHelper.renderCells(masterCrossTab, renderedComponent, pars.startColumn, colIndex + 1, endCol, colIndexEnd + 1, rect);
                                                    rect.y += masterCrossTab.crossTabInfo.cross.heights[colIndex + 1];
                                                }
                                                else {
                                                    StiCrossTabHelper.renderCells(masterCrossTab, renderedComponent, pars.startColumn, colIndex, endCol, colIndexEnd, rect);
                                                    rect.y += masterCrossTab.crossTabInfo.cross.heights[colIndex];
                                                }
                                            }
                                            colIndex = colIndexEnd + 1;
                                        }
                                    }
                                    rect.x = stX;
                                    rect.y = stY;
                                    flag = true;
                                    while (flag) {
                                        flag = false;
                                        endCol = StiCrossTabHelper.getEndCol(masterCrossTab, pars.startColumn, rect);
                                        endRow = StiCrossTabHelper.getEndRow(masterCrossTab, pars.startRow, rect);
                                        if (pars.startRow < endRow) {
                                            StiCrossTabHelper.renderCells(masterCrossTab, renderedComponent, pars.startColumn, pars.startRow, endCol, endRow, rect);
                                        }
                                        pars.renderingIsFinished = (endCol == masterCrossTab.crossTabInfo.cross.colCount) && (endRow == masterCrossTab.crossTabInfo.cross.rowCount);
                                        pars.startColumn = endCol;
                                        if (endCol == masterCrossTab.crossTabInfo.cross.colCount) {
                                            pars.startColumn = 0;
                                            pars.startRow = endRow;
                                        }
                                        // Hor Alignment for placed not on databand
                                        if (!placedOnBand) {
                                            StiCrossTabBuilder.makeHorAlignment(masterCrossTab, renderedComponent, 0, pars.destinationContainer != null ? pars.destinationContainer.width : masterCrossTab.parent.width, 1);
                                        }
                                        // Finalize Cross
                                        if (masterCrossTab.canGrow) {
                                            renderedComponent.canGrow = false;
                                            renderedComponent.canShrink = true;
                                            size = renderedComponent.getActualSize();
                                            renderedComponent.width = size.width;
                                            renderedComponent.height = size.height;
                                            renderedComponent.canGrow = true;
                                        }
                                        if (masterCrossTab.page.unlimitedHeight) {
                                            indexLine = 0;
                                            sumHeight = 0;
                                            while (indexLine < masterCrossTab.crossTabInfo.cross.rowCount) {
                                                sumHeight += masterCrossTab.crossTabInfo.cross.heights[indexLine];
                                                indexLine++;
                                            }
                                            rect.y += sumHeight;
                                            if (pars.renderingIsFinished) {
                                                pars.destinationContainer.containerInfo.setSegmentPerWidth = Math.trunc(rect.y / pars.destinationRectangle.height);
                                            }
                                            else {
                                                flag = true;
                                            }
                                        }
                                    }
                                    return [2 /*return*/, renderedComponent];
                            }
                        });
                    });
                };
                StiCrossTabBuilder.prototype.renderCrossTabUnlimitedBreakable = function (pars, master, destination, rect) {
                    var page = this.getPageForCrossTab(destination);
                    if (page == null)
                        page = master.report.renderedPages.toList().lastOrDefault();
                    var endCol = StiCrossTabHelper.getEndCol(master, pars.startColumn, rect);
                    var endRow = StiCrossTabHelper.getEndRow(master, pars.startRow, rect);
                    var pageWidth = page.width;
                    var pageHeight = page.height;
                    var segmentHeightIndex = 0;
                    var currentRow = 0;
                    while (currentRow < endRow) {
                        page.segmentPerHeight = Math.max(page.segmentPerHeight, segmentHeightIndex + 1);
                        var segmentWidthIndex = 0;
                        var currentCol = { ref: 0 };
                        var reachedRow = { ref: 0 };
                        while (currentCol.ref < endCol) {
                            page.segmentPerWidth = Math.max(page.segmentPerWidth, segmentWidthIndex + 1);
                            var rectSegment = new Rectangle(rect.left + (segmentWidthIndex * pageWidth), rect.top + (segmentHeightIndex * pageHeight), pars.destinationRectangle.width, pars.destinationRectangle.height);
                            pars.startColumn = currentCol.ref;
                            pars.startRow = currentRow;
                            this.renderCrossTabOnPage(pars, master, destination, rectSegment, currentCol, reachedRow);
                            segmentWidthIndex++;
                        }
                        currentRow = reachedRow.ref;
                        segmentHeightIndex++;
                    }
                };
                StiCrossTabBuilder.prototype.getPageForCrossTab = function (destination) {
                    var page = null;
                    var parent = destination;
                    while (page == null && parent != null) {
                        page = parent.page;
                        parent = parent.parent;
                    }
                    return page;
                };
                StiCrossTabBuilder.prototype.getActualHeaderRowCount = function (masterCrossTab) {
                    var headerRowCount = 0;
                    var summaryCount = 0;
                    for (var _i = 0, _a = masterCrossTab.components.list; _i < _a.length; _i++) {
                        var comp = _a[_i];
                        if (comp.sti.is(StiCrossSummary)) {
                            if (comp.enabled)
                                summaryCount++;
                        }
                        if (comp.sti.is(StiCrossColumn)) {
                            if (comp.enabled)
                                headerRowCount++;
                        }
                    }
                    if (summaryCount > 1 && masterCrossTab.summaryDirection == StiSummaryDirection.LeftToRight)
                        headerRowCount++;
                    return headerRowCount;
                };
                StiCrossTabBuilder.prototype.prepare = function (masterComp) {
                    _super.prototype.prepare.call(this, masterComp);
                    StiFilterHelper.setFilter(masterComp);
                };
                StiCrossTabBuilder.prototype.unPrepare = function (masterComp) {
                    _super.prototype.unPrepare.call(this, masterComp);
                    StiCrossTabHelper.clearCross(masterComp.sti.as(StiCrossTab));
                };
                StiCrossTabBuilder.prototype.internalRender = function (masterComp) {
                    return __awaiter(this, void 0, void 0, function () {
                        var masterCrossTab, pars, placedOnBand, band, cont;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0:
                                    masterCrossTab = masterComp.sti.as(StiCrossTab);
                                    pars = new StiCrossTabParams();
                                    placedOnBand = Engine.StiSubReportsHelper.getParentBand(masterCrossTab) != null;
                                    pars.allowRendering = placedOnBand;
                                    band = masterComp.parent.sti.as(StiDataBand);
                                    if (band != null)
                                        pars.destinationRectangle = band.parent.clientRectangle.clone();
                                    else
                                        pars.destinationRectangle = masterCrossTab.clientRectangle.clone();
                                    if (!placedOnBand) return [3 /*break*/, 2];
                                    StiCrossTabHelper.createCross(masterCrossTab);
                                    return [4 /*yield*/, this.renderCrossTab(pars, masterCrossTab)];
                                case 1: return [2 /*return*/, _a.sent()];
                                case 2: return [4 /*yield*/, _super.prototype.internalRender.call(this, masterComp)];
                                case 3:
                                    cont = (_a.sent()).sti.as(StiContainer);
                                    if (cont != null) {
                                        cont.width = masterComp.width;
                                        cont.height = masterComp.height;
                                        cont.components.clear();
                                    }
                                    return [2 /*return*/, cont];
                            }
                        });
                    });
                };
                return StiCrossTabBuilder;
            }(Engine.StiContainerBuilder));
            Engine.StiCrossTabBuilder = StiCrossTabBuilder;
        })(Engine = Report.Engine || (Report.Engine = {}));
    })(Report = Stimulsoft.Report || (Stimulsoft.Report = {}));
})(Stimulsoft || (Stimulsoft = {}));


var Stimulsoft;
(function (Stimulsoft) {
    var Report;
    (function (Report) {
        var CrossTab;
        (function (CrossTab) {
            var Core;
            (function (Core) {
                var StiString = Stimulsoft.System.StiString;
                var StiDataTopNMode = Stimulsoft.Data.Engine.StiDataTopNMode;
                var List = Stimulsoft.System.Collections.List;
                var StiGeneralFormatService = Stimulsoft.Report.Components.TextFormats.StiGeneralFormatService;
                var EventArgs = Stimulsoft.System.EventArgs;
                var DBNull = Stimulsoft.System.Data.DBNull;
                var DateTime = Stimulsoft.System.DateTime;
                var StiFormatService = Stimulsoft.Report.Components.TextFormats.StiFormatService;
                var StiComponentsCollection = Stimulsoft.Report.Components.StiComponentsCollection;
                var Rectangle = Stimulsoft.System.Drawing.Rectangle;
                var StiValueEventArgs = Stimulsoft.Report.Events.StiValueEventArgs;
                var Char = Stimulsoft.System.Char;
                var StiGetValueEventArgs = Stimulsoft.Report.Events.StiGetValueEventArgs;
                var Hashtable = Stimulsoft.System.Collections.Hashtable;
                var Guid = Stimulsoft.System.Guid;
                var Type = Stimulsoft.System.Type;
                var StiValueHelper = Stimulsoft.Base.Helpers.StiValueHelper;
                var StiCross = /** @class */ (function (_super) {
                    __extends(StiCross, _super);
                    function StiCross() {
                        var _this = _super !== null && _super.apply(this, arguments) || this;
                        _this.crossTab = null;
                        _this.strNull = "";
                        _this.emptyField = StiCross.emptyField;
                        _this.oneCellSize = 0;
                        _this.oneCellWidth = 0;
                        _this.oneCellHeight = 0;
                        _this.summaryDirection = Core.StiSummaryDirection.LeftToRight;
                        _this.widthCorrection = 0;
                        _this.heightCorrection = 0;
                        _this.columnsCell = new Hashtable();
                        _this.rowsCell = new Hashtable();
                        _this.rows = new Core.StiRowCollection();
                        _this.cols = new Core.StiColumnCollection();
                        _this.summaryContainer = null;
                        _this.leftCrossTitle = null;
                        _this.rightCrossTitle = null;
                        _this.summaryCrossTitle = null;
                        return _this;
                    }
                    StiCross.prototype.invokeEvents2 = function (component, displayValue) {
                        var isCompilationMode = true;
                        if (this.report != null)
                            isCompilationMode = this.report.calculationMode == Report.StiCalculationMode.Compilation;
                        if (isCompilationMode) {
                            // Process Hyperlink
                            var e1 = new StiValueEventArgs();
                            e1.displayValue = displayValue;
                            component.invokeGetHyperlink(component, e1);
                            component.hyperlinkValue = e1.value;
                            // Process ToolTip
                            var e2 = new StiValueEventArgs();
                            e2.displayValue = displayValue;
                            component.invokeGetToolTip(component, e2);
                            component.toolTipValue = e2.value;
                            // Process Tag
                            var e3 = new StiValueEventArgs();
                            e3.displayValue = displayValue;
                            component.invokeGetTag(component, e3);
                            component.tagValue = e3.value;
                        }
                        else {
                            // Process Hyperlink
                            if (component.hyperlink.length > 0) {
                                var parserResult = Stimulsoft.Report.Engine.StiParser.StiParser.parseTextValue(component.hyperlink, component);
                                component.hyperlinkValue = this.report.toString2(parserResult);
                            }
                            // Process ToolTip
                            if (component.toolTip.length > 0) {
                                var parserResult = Stimulsoft.Report.Engine.StiParser.StiParser.parseTextValue(component.toolTip, component);
                                component.toolTipValue = this.report.toString2(parserResult);
                            }
                            // Process Tag
                            if (component.tag.length > 0) {
                                var parserResult = Stimulsoft.Report.Engine.StiParser.StiParser.parseTextValue(component.tag, component);
                                component.tagValue = this.report.toString2(parserResult);
                            }
                        }
                        component.invokeBeforePrint(component, EventArgs.empty);
                        component.invokeAfterPrint(component, EventArgs.empty);
                    };
                    StiCross.prototype.invokeEvents = function (component) {
                        var isCompilationMode = true;
                        if (this.report != null)
                            isCompilationMode = this.report.calculationMode == Report.StiCalculationMode.Compilation;
                        if (isCompilationMode) {
                            // Process Hyperlink
                            var e1 = new StiValueEventArgs();
                            component.invokeGetHyperlink(component, e1);
                            component.hyperlinkValue = e1.value;
                            // Process ToolTip
                            var e2 = new StiValueEventArgs();
                            component.invokeGetToolTip(component, e2);
                            component.toolTipValue = e2.value;
                            // Process Tag
                            var e3 = new StiValueEventArgs();
                            component.invokeGetTag(component, e3);
                            component.tagValue = e3.value;
                        }
                        else {
                            // Process Hyperlink
                            if (component.hyperlink.length > 0) {
                                var parserResult = Stimulsoft.Report.Engine.StiParser.StiParser.parseTextValue(component.hyperlink, component);
                                component.hyperlinkValue = this.report.toString2(parserResult);
                            }
                            // Process ToolTip
                            if (component.toolTip.length > 0) {
                                var parserResult = Stimulsoft.Report.Engine.StiParser.StiParser.parseTextValue(component.toolTip, component);
                                component.toolTipValue = this.report.toString2(parserResult);
                            }
                            // Process Tag
                            if (component.tag.length > 0) {
                                var parserResult = Stimulsoft.Report.Engine.StiParser.StiParser.parseTextValue(component.tag, component);
                                component.tagValue = this.report.toString2(parserResult);
                            }
                        }
                        component.invokeBeforePrint(component, EventArgs.empty);
                        component.invokeAfterPrint(component, EventArgs.empty);
                    };
                    StiCross.prototype.addRowTotal = function (rows, level, maxLevel, setLevel) {
                        while (true) {
                            var row = new Core.StiRow("", "");
                            row.isTotal = true;
                            row.level = setLevel;
                            var e = new StiGetValueEventArgs();
                            var total = this.rowFields.getByIndex(setLevel).total;
                            if (total != null)
                                total.invokeGetValue(total, e);
                            row.displayValue = e.value;
                            rows.add(row);
                            level++;
                            if (level >= maxLevel)
                                return;
                            rows = rows.getByIndex(rows.count - 1).rows;
                        }
                    };
                    StiCross.prototype.addColTotal = function (cols, level, maxLevel, setLevel) {
                        while (true) {
                            var col = new Core.StiColumn("", "");
                            col.isTotal = true;
                            col.level = setLevel;
                            var e = new StiGetValueEventArgs();
                            var total = this.colFields.getByIndex(setLevel).total;
                            if (total != null)
                                total.invokeGetValue(total, e);
                            col.displayValue = e.value;
                            cols.add(col);
                            level++;
                            if (level >= maxLevel)
                                return;
                            cols = cols.getByIndex(cols.count - 1).cols;
                        }
                    };
                    StiCross.prototype.sortRows = function (rows, level, width) {
                        if (rows === void 0) { rows = this.rows; }
                        if (level === void 0) { level = 0; }
                        if (width === void 0) { width = this.getRowsHeaderWidth(); }
                        for (var _i = 0, _a = rows.list; _i < _a.length; _i++) {
                            var row = _a[_i];
                            this.sortRows(row.rows, level + 1, width);
                        }
                        if (level < width) {
                            var sortDirection = this.rowFields.getByIndex(level).sortDirection;
                            if (sortDirection != Core.StiSortDirection.None)
                                rows.sort(sortDirection, this.rowFields.getByIndex(level).sortType);
                        }
                    };
                    StiCross.prototype.sortCols = function (cols, level, height) {
                        if (cols === void 0) { cols = this.cols; }
                        if (level === void 0) { level = 0; }
                        if (height === void 0) { height = this.getColsHeaderHeight(); }
                        for (var _i = 0, _a = cols.list; _i < _a.length; _i++) {
                            var col = _a[_i];
                            this.sortCols(col.cols, level + 1, height);
                        }
                        if (level < height) {
                            var sortDirection = this.colFields.getByIndex(level).sortDirection;
                            if (sortDirection != Core.StiSortDirection.None)
                                cols.sort(sortDirection, this.colFields.getByIndex(level).sortType);
                        }
                    };
                    StiCross.prototype.createRowTotals = function () {
                        var maxLevel = this.getRowsHeaderWidth();
                        if (maxLevel > 0) {
                            this.createRowTotals2(this.rows, 0, maxLevel);
                        }
                    };
                    StiCross.prototype.createRowTotals2 = function (rows, level, maxLevel) {
                        if (rows.count > 0) {
                            for (var _i = 0, _a = rows.list; _i < _a.length; _i++) {
                                var row = _a[_i];
                                this.createRowTotals2(row.rows, level + 1, maxLevel);
                            }
                            var curField = this.rowFields.getByIndex(level).sti.as(CrossTab.StiCrossRow);
                            var prevField = level == 0 ? null : this.rowFields.getByIndex(level - 1).sti.as(CrossTab.StiCrossRow);
                            if (this.allowTotal(curField, prevField)) {
                                this.addRowTotal(rows, level, maxLevel, level);
                            }
                        }
                    };
                    StiCross.prototype.createColTotals = function () {
                        var maxLevel = this.getColsHeaderHeight();
                        if (maxLevel > 0) {
                            this.createColTotals2(this.cols, 0, maxLevel);
                        }
                    };
                    StiCross.prototype.createColTotals2 = function (cols, level, maxLevel) {
                        if (cols.count > 0) {
                            for (var _i = 0, _a = cols.list; _i < _a.length; _i++) {
                                var col = _a[_i];
                                this.createColTotals2(col.cols, level + 1, maxLevel);
                            }
                            var curField = this.colFields.getByIndex(level).sti.as(CrossTab.StiCrossColumn);
                            var prevField = level == 0 ? null : this.colFields.getByIndex(level - 1).sti.as(CrossTab.StiCrossColumn);
                            if (this.allowTotal(curField, prevField)) {
                                this.addColTotal(cols, level, maxLevel, level);
                            }
                        }
                    };
                    StiCross.prototype.getDataFromDataRow = function (dataRow, field) {
                        if (dataRow == null)
                            return this.strNull;
                        return dataRow.gett(field) != null ? dataRow.gett(field) : this.strNull;
                    };
                    StiCross.prototype.getValueFromDataRow = function (dataRow, field) {
                        if (dataRow == null)
                            return null;
                        try {
                            var value = dataRow.gett(field.name);
                            var summaryType = field.summary;
                            // StiSummaryType.Image
                            if (summaryType == Core.StiSummaryType.Image) {
                                return value;
                            }
                            // StiSummaryType.Count
                            else if (summaryType == Core.StiSummaryType.Count) {
                                return value;
                            }
                            // StiSummaryType.CountDistinct
                            else if (summaryType == Core.StiSummaryType.CountDistinct) {
                                return value;
                            }
                            // StiSummaryType.None
                            else if (summaryType == Core.StiSummaryType.None) {
                                if (value.sti.is(DateTime) /* || value.sti.is(DateTime?)*/)
                                    return value;
                                if (!field.hideZeros)
                                    return value;
                                else {
                                    var valueObj = 0;
                                    try {
                                        if (value.sti.is(String)) {
                                            var text = value.toString();
                                            // Проверяем если хоть одна цифра в строке и если есть то только тогда предпринимаем попытку преобразовать строку в число
                                            var isDigit = false;
                                            for (var index = 0; index < text.length; index++) {
                                                if (Char.isDigit(text[index])) {
                                                    isDigit = true;
                                                    break;
                                                }
                                            }
                                            if (isDigit) {
                                                text = text.replace(".", ",").replace(",", Stimulsoft.System.Globalization.CultureInfo.currentCulture.numberFormat.numberDecimalSeparator).sti.replaceAll(" ", "");
                                                valueObj = text.sti.toNumber();
                                            }
                                            else
                                                return value;
                                        }
                                        else {
                                            valueObj = Stimulsoft.System.Convert.changeType(value, Number);
                                        }
                                        if (valueObj == 0)
                                            return "";
                                    }
                                    catch (e) {
                                    }
                                    return value;
                                }
                            }
                            // Others
                            else {
                                if (value.sti.is(String)) {
                                    var text = value.toString();
                                    if (text.length == 0)
                                        return null;
                                    text = text.replace(".", ",").replace(",", Stimulsoft.System.Globalization.CultureInfo.currentCulture.numberFormat.numberDecimalSeparator);
                                    var result = text.sti.toNumber();
                                    return isNaN(result) ? 0 : result;
                                }
                                else if (value.sti.is(DateTime) /* || value.sti.is(DateTime?)*/) {
                                    return value;
                                }
                                else {
                                    if (value == null)
                                        return 0;
                                    if (value == DBNull)
                                        return 0;
                                    return Stimulsoft.System.Convert.changeType(value, Number);
                                }
                            }
                        }
                        catch (e) {
                            return 0;
                        }
                    };
                    StiCross.prototype.allowTotal = function (row, prevRow) {
                        if (row == null)
                            return false;
                        if (prevRow != null) {
                            var interaction = prevRow.interaction == null ? null : prevRow.interaction.sti.as(Stimulsoft.Report.Components.StiCrossHeaderInteraction);
                            if (interaction != null && interaction.collapsingEnabled)
                                return false;
                        }
                        return row.isTotalVisible;
                    };
                    StiCross.prototype.getRow = function (dataRow) {
                        var split = false;
                        var curRows = this.rows;
                        var selectedRow = null;
                        var level = 0;
                        for (var _i = 0, _a = this.rowFields.toCast(); _i < _a.length; _i++) {
                            var rowField = _a[_i];
                            var value = this.strNull;
                            var displayValue = this.strNull;
                            if (rowField.name != this.emptyField) {
                                value = this.getDataFromDataRow(dataRow, rowField.name);
                                displayValue = this.getDataFromDataRow(dataRow, "Display__" + rowField.name);
                            }
                            if (split) {
                                value = "all";
                                displayValue = "all";
                            }
                            selectedRow = curRows.getByValue(value);
                            if (selectedRow == null) {
                                selectedRow = new Core.StiRow(value, displayValue);
                                // Process Hyperlink
                                var e1 = new StiValueEventArgs();
                                rowField.invokeGetHyperlink(rowField, e1);
                                selectedRow.hyperlinkValue = e1.value;
                                // Process ToolTip
                                var e2 = new StiValueEventArgs();
                                rowField.invokeGetToolTip(rowField, e2);
                                selectedRow.toolTipValue = e2.value;
                                // Process Tag
                                var e3 = new StiValueEventArgs();
                                rowField.invokeGetTag(rowField, e3);
                                selectedRow.tagValue = e3.value;
                                curRows.add(selectedRow);
                            }
                            split = rowField.sti.is(CrossTab.StiCrossHeader) && Stimulsoft.Report.Engine.StiCrossTabBuilder.isCollapsed2(rowField.sti.as(CrossTab.StiCrossHeader), level, value.toString());
                            curRows = selectedRow.rows;
                            level++;
                        }
                        return selectedRow;
                    };
                    StiCross.prototype.getColumn = function (dataRow) {
                        var split = false;
                        var curCols = this.cols;
                        var selectedCol = null;
                        var level = 0;
                        for (var _i = 0, _a = this.colFields.toCast(); _i < _a.length; _i++) {
                            var colField = _a[_i];
                            var value = "";
                            var displayValue = "";
                            if (colField.name != this.emptyField) {
                                value = this.getDataFromDataRow(dataRow, colField.name);
                                displayValue = this.getDataFromDataRow(dataRow, "Display__" + colField.name);
                            }
                            if (split) {
                                value = "all";
                                displayValue = "all";
                            }
                            selectedCol = curCols.getByValue(value);
                            if (selectedCol == null) {
                                selectedCol = new Core.StiColumn(value, displayValue);
                                // Process Hyperlink
                                var e1 = new StiValueEventArgs();
                                colField.invokeGetHyperlink(colField, e1);
                                selectedCol.hyperlinkValue = e1.value;
                                // Process ToolTip
                                var e2 = new StiValueEventArgs();
                                colField.invokeGetToolTip(colField, e2);
                                selectedCol.toolTipValue = e2.value;
                                // Process Tag
                                var e3 = new StiValueEventArgs();
                                colField.invokeGetTag(colField, e3);
                                selectedCol.tagValue = e3.value;
                                curCols.add(selectedCol);
                            }
                            split = colField.sti.is(CrossTab.StiCrossHeader) && Stimulsoft.Report.Engine.StiCrossTabBuilder.isCollapsed2(colField.sti.as(CrossTab.StiCrossHeader), level, value.toString());
                            curCols = selectedCol.cols;
                            level++;
                        }
                        return selectedCol;
                    };
                    StiCross.prototype.calculateTopN = function () {
                        for (var level = this.colFields.count - 1; level >= 0; level--) {
                            var colField = this.colFields.getByIndex(level);
                            var sumIndex = this.getSumFiledIndex(colField.topN);
                            if (sumIndex >= 0)
                                this.processTopNColumns(level, 0, sumIndex, this.cols, colField.topN);
                        }
                        for (var level = this.rowFields.count - 1; level >= 0; level--) {
                            var rowField = this.rowFields.getByIndex(level);
                            var sumIndex = this.getSumFiledIndex(rowField.topN);
                            if (sumIndex >= 0)
                                this.processTopNRows(level, 0, sumIndex, this.rows, rowField.topN);
                        }
                    };
                    StiCross.prototype.processTopNRows = function (level, curLevel, sumIndex, rows, topN) {
                        if (curLevel < level)
                            for (var _i = 0, _a = rows.list; _i < _a.length; _i++) {
                                var row = _a[_i];
                                this.processTopNRows(level, curLevel + 1, sumIndex, row.rows, topN);
                            }
                        else {
                            // let values = new SortedList();
                            var values = new Hashtable();
                            for (var _b = 0, _c = rows.list; _b < _c.length; _b++) {
                                var row = _c[_b];
                                var array = new List();
                                this.getRowsArray2(row.rows, array);
                                if (array.length == 0)
                                    array.add(row);
                                var sums = [];
                                for (var _d = 0, array_1 = array; _d < array_1.length; _d++) {
                                    var srow = array_1[_d];
                                    for (var _e = 0, _f = this.summaryContainer.getDataCol().keys; _e < _f.length; _e++) {
                                        var col = _f[_e];
                                        var summary = this.summaryContainer.getDataCol().get(col).get(srow);
                                        if (summary != null)
                                            summary = summary.sti.as(Core.StiSummary);
                                        if (summary != null)
                                            for (var _g = 0, _h = summary.sums[sumIndex]; _g < _h.length; _g++) {
                                                var val = _h[_g];
                                                sums.add(val);
                                            }
                                    }
                                }
                                var value = this.getSummaryResult(sums, sumIndex, false);
                                if (values.get(value) == null)
                                    values.set(value, new List());
                                values.get(value).add(row);
                            }
                            var sortedRows = new List();
                            for (var _j = 0, _k = values.keys; _j < _k.length; _j++) {
                                var value = _k[_j];
                                sortedRows.addRange(values.get(value));
                            }
                            var resultRows = new List();
                            for (var i = (topN.mode == StiDataTopNMode.Top ? Math.max(0, sortedRows.length - topN.count) : 0); i < (topN.mode == StiDataTopNMode.Top ? sortedRows.length : Math.min(sortedRows.length, topN.count)); i++)
                                resultRows.add(sortedRows[i]);
                            var j = 0;
                            var otherRows = new List();
                            while (j < rows.count)
                                if (!resultRows.contains(rows.getByIndex(j))) {
                                    otherRows.add(rows.getByIndex(j));
                                    rows.removeAt(j);
                                }
                                else
                                    j++;
                            if (topN.showOthers && otherRows.length > 0) {
                                var otherRow = new Core.StiRow(topN.othersText, topN.othersText);
                                otherRow.othersText = topN.othersText;
                                rows.add(otherRow);
                                this.fillOtherRows(otherRow, otherRows);
                            }
                        }
                    };
                    StiCross.prototype.fillOtherRows = function (otherRow, rows) {
                        for (var _i = 0, rows_1 = rows; _i < rows_1.length; _i++) {
                            var row = rows_1[_i];
                            if (row.rows.count == 0) {
                                for (var _a = 0, _b = this.summaryContainer.getDataCol().keys; _a < _b.length; _a++) {
                                    var col = _b[_a];
                                    var summary = this.summaryContainer.getDataCol().get(col).get(row);
                                    if (summary != null)
                                        summary = summary.sti.as(Core.StiSummary);
                                    if (summary != null) {
                                        var otherSummary = this.summaryContainer.getSummary(col, otherRow);
                                        var index = 0;
                                        for (var _c = 0, _d = this.sumFields.list; _c < _d.length; _c++) {
                                            var field = _d[_c];
                                            if (field.name != this.emptyField) {
                                                if (otherSummary.sums[index].length == 0) {
                                                    otherSummary.hyperlinkValues = summary.hyperlinkValues;
                                                    otherSummary.toolTipValues = summary.toolTipValues;
                                                    otherSummary.tagValues = summary.tagValues;
                                                    otherSummary.drillDownParameters = summary.drillDownParameters;
                                                }
                                                otherSummary.sums[index].addRange(summary.sums[index]);
                                                index++;
                                            }
                                        }
                                    }
                                }
                            }
                            else {
                                for (var _e = 0, _f = row.rows.list; _e < _f.length; _e++) {
                                    var sRow = _f[_e];
                                    if (otherRow.rows.getByValue(sRow.value) == null)
                                        otherRow.rows.add(sRow);
                                    else {
                                        var otherRows = new List();
                                        otherRows.add(sRow);
                                        this.fillOtherRows(otherRow.rows.getByValue(sRow.value), otherRows);
                                    }
                                }
                            }
                        }
                    };
                    StiCross.prototype.processTopNColumns = function (level, curLevel, sumIndex, cols, topN) {
                        if (curLevel < level)
                            for (var _i = 0, _a = cols.list; _i < _a.length; _i++) {
                                var col = _a[_i];
                                this.processTopNColumns(level, curLevel + 1, sumIndex, col.cols, topN);
                            }
                        else {
                            // let values = new SortedList();
                            var values = new Hashtable();
                            for (var _b = 0, _c = cols.list; _b < _c.length; _b++) {
                                var col = _c[_b];
                                var array = new List();
                                this.getColsArray2(col.cols, array);
                                if (array.length == 0)
                                    array.add(col);
                                var sums = [];
                                for (var _d = 0, array_2 = array; _d < array_2.length; _d++) {
                                    var scol = array_2[_d];
                                    var dataRow = this.summaryContainer.getDataCol().get(scol).sti.as(Hashtable);
                                    if (dataRow != null)
                                        for (var _e = 0, _f = dataRow.values; _e < _f.length; _e++) {
                                            var summary = _f[_e];
                                            for (var _g = 0, _h = summary.sums[sumIndex]; _g < _h.length; _g++) {
                                                var val = _h[_g];
                                                sums.add(val);
                                            }
                                        }
                                }
                                var value = this.getSummaryResult(sums, sumIndex, false);
                                if (values.get(value) == null)
                                    values.set(value, new List());
                                values.get(value).add(col);
                            }
                            var sortedCols = new List();
                            for (var _j = 0, _k = values.keys; _j < _k.length; _j++) {
                                var value = _k[_j];
                                sortedCols.addRange(values.get(value));
                            }
                            var resultCols = new List();
                            for (var i = (topN.mode == StiDataTopNMode.Top ? Math.max(0, sortedCols.length - topN.count) : 0); i < (topN.mode == StiDataTopNMode.Top ? sortedCols.length : Math.min(sortedCols.length, topN.count)); i++)
                                resultCols.add(sortedCols[i]);
                            var j = 0;
                            var otherCols = new List();
                            while (j < cols.count)
                                if (!resultCols.contains(cols.getByIndex(j))) {
                                    otherCols.add(cols.getByIndex(j));
                                    cols.removeAt(j);
                                }
                                else
                                    j++;
                            if (topN.showOthers && otherCols.length > 0) {
                                var otherCol = new Core.StiColumn(topN.othersText, topN.othersText);
                                otherCol.othersText = topN.othersText;
                                cols.add(otherCol);
                                this.fillOtherColumns(otherCol, otherCols);
                            }
                        }
                    };
                    StiCross.prototype.fillOtherColumns = function (otherCol, cols) {
                        for (var _i = 0, cols_1 = cols; _i < cols_1.length; _i++) {
                            var col = cols_1[_i];
                            if (col.cols.count == 0) {
                                var dataRow = this.summaryContainer.getDataCol().get(col).sti.as(Hashtable);
                                if (dataRow != null)
                                    for (var _a = 0, _b = dataRow.keys; _a < _b.length; _a++) {
                                        var row = _b[_a];
                                        var otherSummary = this.summaryContainer.getSummary(otherCol, row);
                                        var summary = dataRow.get(row);
                                        var index = 0;
                                        for (var _c = 0, _d = this.sumFields.list; _c < _d.length; _c++) {
                                            var field = _d[_c];
                                            if (field.name != this.emptyField) {
                                                if (otherSummary.sums[index].length == 0) {
                                                    otherSummary.hyperlinkValues = summary.hyperlinkValues;
                                                    otherSummary.toolTipValues = summary.toolTipValues;
                                                    otherSummary.tagValues = summary.tagValues;
                                                    otherSummary.drillDownParameters = summary.drillDownParameters;
                                                }
                                                otherSummary.sums[index].addRange(summary.sums[index]);
                                                index++;
                                            }
                                        }
                                    }
                            }
                            else {
                                for (var _e = 0, _f = col.cols.list; _e < _f.length; _e++) {
                                    var sCol = _f[_e];
                                    if (otherCol.cols.getByValue(sCol.value) == null)
                                        otherCol.cols.add(sCol);
                                    else {
                                        var otherCols = new List();
                                        otherCols.add(sCol);
                                        this.fillOtherColumns(otherCol.cols.getByValue(sCol.value), otherCols);
                                    }
                                }
                            }
                        }
                    };
                    StiCross.prototype.getSumFiledIndex = function (topN) {
                        if (topN != null && topN.mode != StiDataTopNMode.None && !StiString.isNullOrEmpty(topN.measureField)) {
                            for (var i = 0; i < this.sumFields.count; i++)
                                if (this.sumFields.getByIndex(i).alias.sti.endsWith(topN.measureField + ")"))
                                    return i;
                        }
                        return -1;
                    };
                    StiCross.prototype.calculateDataTable = function (table) {
                        if (table == null || table.rows.count == 0)
                            this.calculateDataRow(null);
                        else {
                            // Process DataSource
                            if (this.crossTab.dataSource != null) {
                                var resPosition = this.crossTab.dataSource.position;
                                var index = 0;
                                for (var _i = 0, _a = table.rows.list; _i < _a.length; _i++) {
                                    var dataRow = _a[_i];
                                    this.crossTab.dataSource.position = index++;
                                    this.calculateDataRow(dataRow);
                                }
                                this.crossTab.dataSource.position = resPosition;
                            }
                            // Process BusinessObject
                            else if (this.crossTab.businessObject != null) {
                                var resPosition = this.crossTab.businessObject.position;
                                var index = 0;
                                for (var _b = 0, _c = table.rows.list; _b < _c.length; _b++) {
                                    var dataRow = _c[_b];
                                    this.crossTab.businessObject.position = index++;
                                    this.calculateDataRow(dataRow);
                                }
                                this.crossTab.businessObject.position = resPosition;
                            }
                        }
                    };
                    StiCross.prototype.calculateDataRow = function (dataRow) {
                        var row = this.getRow(dataRow);
                        var col = this.getColumn(dataRow);
                        // Calc Summary Data
                        var summary = this.summaryContainer.getSummary(col, row);
                        var index = 0;
                        for (var _i = 0, _a = this.sumFields.toCast(); _i < _a.length; _i++) {
                            var field = _a[_i];
                            if (field.name != this.emptyField) {
                                var summaryValue = this.getValueFromDataRow(dataRow, field);
                                summary.sums[index].add(summaryValue);
                                this.invokeEvents(field);
                                summary.hyperlinkValues[index] = field.hyperlinkValue;
                                summary.toolTipValues[index] = field.toolTipValue;
                                summary.tagValues[index] = field.tagValue;
                                if (field.drillDownParameters != null) {
                                    if (summary.drillDownParameters == null)
                                        summary.drillDownParameters = Array.create(Object, summary.tagValues.length);
                                    summary.drillDownParameters[index] = field.drillDownParameters;
                                }
                                index++;
                            }
                        }
                        // Calc Row Data
                        for (var _b = 0, _c = this.rowFields.toCast(); _b < _c.length; _b++) {
                            var field = _c[_b];
                            if (field.name != this.emptyField) {
                                this.invokeEvents(field);
                                row.hyperlinkValue = field.hyperlinkValue;
                                row.toolTipValue = field.toolTipValue;
                                row.tagValue = field.tagValue;
                                if (field.drillDownParameters != null) {
                                    if (row.drillDownParameters == null)
                                        row.drillDownParameters = {};
                                    row.drillDownParameters = field.drillDownParameters;
                                }
                            }
                        }
                        // Calc Col Data
                        for (var _d = 0, _e = this.colFields.toCast(); _d < _e.length; _d++) {
                            var field = _e[_d];
                            if (field.name != this.emptyField) {
                                this.invokeEvents(field);
                                col.hyperlinkValue = field.hyperlinkValue;
                                col.toolTipValue = field.toolTipValue;
                                col.tagValue = field.tagValue;
                                if (field.drillDownParameters != null) {
                                    if (col.drillDownParameters == null)
                                        col.drillDownParameters = {};
                                    col.drillDownParameters = field.drillDownParameters;
                                }
                            }
                        }
                    };
                    StiCross.prototype.copyRows = function (rows, left, top, level, emptyValue, colsWidth, parentGuid) {
                        var rowCount = 0;
                        parentGuid.ref = Guid.newGuid().toString();
                        for (var _i = 0, _a = rows.list; _i < _a.length; _i++) {
                            var row = _a[_i];
                            var childrenGuid = { ref: "" };
                            var curRowCount = this.copyRows(row.rows, left + 1, top, level + 1, emptyValue, colsWidth, childrenGuid);
                            var field = this.rowFields.getByIndex(level).sti.as(CrossTab.StiCrossField);
                            rowCount += curRowCount;
                            // Calculate Total Width
                            var totalWidth = 1;
                            if (Stimulsoft.Report.Engine.StiCrossTabBuilder.isCollapsed2(field.sti.as(CrossTab.StiCrossHeader), level, row.value.toString())) {
                                var selectedRow = row;
                                while (true) {
                                    if (selectedRow.rows.count == 0)
                                        break;
                                    totalWidth++;
                                    selectedRow = selectedRow.rows.getByIndex(0);
                                }
                            }
                            var rect = new Rectangle(left, top, totalWidth, curRowCount);
                            if (row.isTotal) {
                                rect.width = this.rowsHeaderWidth + this.widthCorrection - rect.x - ((this.isSummarySubHeadersPresent && this.summaryDirection == Core.StiSummaryDirection.UpToDown) ? 1 : 0);
                                field = field.total;
                            }
                            var str = field.textFormat.format(row.displayValue);
                            this.invokeEvents2(field, str);
                            var isNumeric = field != null && field.sti.is(Stimulsoft.Report.CrossTab.StiCrossRow) && !(field.textFormat.sti.is(StiGeneralFormatService));
                            // SetCells
                            if (field.mergeHeaders || this.report.isDesigning) {
                                this.setCell(rect.x, rect.y, rect.width, rect.height, str, str, field, isNumeric, row.hyperlinkValue, row.toolTipValue, row.tagValue, row.drillDownParameters, level, parentGuid.ref, childrenGuid.ref);
                            }
                            else {
                                for (var index = 0; index < rect.height; index++) {
                                    this.setCell(rect.x, rect.y + index, rect.width, 1, str, str, field, isNumeric, row.hyperlinkValue, row.toolTipValue, row.tagValue, row.drillDownParameters, level, parentGuid.ref, childrenGuid.ref);
                                }
                            }
                            top += rect.height;
                        }
                        return Math.max(rowCount, this.oneCellHeight);
                    };
                    StiCross.prototype.copyCols = function (cols, left, top, level, emptyValue, rowsHeight, parentGuid) {
                        var colCount = 0;
                        parentGuid.ref = Guid.newGuid().toString();
                        for (var _i = 0, _a = cols.list; _i < _a.length; _i++) {
                            var col = _a[_i];
                            var guid = { ref: "" };
                            var curColCount = this.copyCols(col.cols, left, top + 1, level + 1, emptyValue, rowsHeight, guid);
                            var field = this.colFields.getByIndex(level).sti.as(CrossTab.StiCrossField);
                            colCount += curColCount;
                            // Calculate Total Height
                            var totalHeight = 1;
                            if (Stimulsoft.Report.Engine.StiCrossTabBuilder.isCollapsed2(field.sti.as(CrossTab.StiCrossHeader), level, col.value.toString())) {
                                var selectedCol = col;
                                while (true) {
                                    if (selectedCol.cols.count == 0)
                                        break;
                                    totalHeight++;
                                    selectedCol = selectedCol.cols.getByIndex(0);
                                }
                            }
                            var rect = new Rectangle(left, top, curColCount, totalHeight);
                            if (col.isTotal) {
                                rect.height = this.colsHeaderHeight + this.heightCorrection - rect.y - ((this.isSummarySubHeadersPresent && this.summaryDirection == Core.StiSummaryDirection.LeftToRight) ? 1 : 0);
                                field = field.total;
                            }
                            var str = field.textFormat.format(col.displayValue);
                            this.invokeEvents2(field, str);
                            var isNumeric = field != null && field.sti.is(Stimulsoft.Report.CrossTab.StiCrossColumn) && !(field.textFormat.sti.is(StiGeneralFormatService));
                            // SetCells
                            if (field.mergeHeaders || this.report.isDesigning) {
                                this.setCell(rect.x, rect.y, rect.width, rect.height, str, str, field, isNumeric, col.hyperlinkValue, col.toolTipValue, col.tagValue, col.drillDownParameters, level, parentGuid.ref, guid.ref);
                            }
                            else {
                                for (var index = 0; index < rect.width; index++) {
                                    this.setCell(rect.x + index, rect.y, 1, rect.height, str, str, field, isNumeric, col.hyperlinkValue, col.toolTipValue, col.tagValue, col.drillDownParameters, level, parentGuid.ref, guid.ref);
                                }
                            }
                            left += rect.width;
                        }
                        return Math.max(colCount, this.oneCellWidth);
                    };
                    StiCross.prototype.convertToDecimal = function (value) {
                        try {
                            if (value.sti.is(String) && (value.toString() == "-" || value.toString() == ""))
                                return 0;
                            return value.sti.toNumber();
                        }
                        catch (e) {
                            return 0;
                        }
                    };
                    StiCross.prototype.isAllowConvertToDecimal = function (value) {
                        if (value == null || DBNull.sti.equals(value))
                            return false;
                        if (value.sti.is(Number))
                            return true;
                        return false;
                    };
                    StiCross.prototype.getSummary2 = function (sums, sumIndex, grandTotal, isMegaTotal) {
                        if (isMegaTotal === void 0) { isMegaTotal = false; }
                        var sumField = this.sumFields.getByIndex(sumIndex);
                        var value = this.getSummaryResult(sums, sumIndex, grandTotal, isMegaTotal);
                        return this.isHideZeros(value) && sumField.hideZeros ? this.crossTab.emptyValue : value;
                    };
                    StiCross.prototype.getSummaryResult = function (sums, totalIndex, grandTotal, isMegaTotal) {
                        if (isMegaTotal === void 0) { isMegaTotal = false; }
                        var crossSummary = this.sumFields.getByIndex(totalIndex).sti.as(CrossTab.StiCrossSummary);
                        var summaryType = crossSummary.summary;
                        var summaryValues = crossSummary.summaryValues;
                        if (grandTotal &&
                            (summaryType == Core.StiSummaryType.Count || summaryType == Core.StiSummaryType.CountDistinct))
                            summaryType = Core.StiSummaryType.Sum;
                        // fixed by Nikolay 20131007: правая нижняя суммарная ячейка (сумма сумм) - считается суммой по агрегаторам каунт и каунтдистинкт
                        if (isMegaTotal &&
                            (summaryType == Core.StiSummaryType.Count ||
                                summaryType == Core.StiSummaryType.CountDistinct))
                            summaryType = Core.StiSummaryType.Sum;
                        var value = 0;
                        var isNull = true;
                        switch (summaryType) {
                            // None, Image
                            case Core.StiSummaryType.None:
                            case Core.StiSummaryType.Image:
                                var indexToUse = 0;
                                if (totalIndex != 0) {
                                    for (var index = totalIndex - 1; index >= 0; index--) {
                                        if (this.sumFields.getByIndex(index).indexOfSelectValue != -1) {
                                            indexToUse = this.sumFields.getByIndex(index).indexOfSelectValue;
                                            if (indexToUse < sums.length)
                                                break;
                                            else
                                                indexToUse = 0;
                                        }
                                    }
                                }
                                if (sums == null || sums.length == 0)
                                    return "";
                                return sums[indexToUse];
                            // Sum
                            case Core.StiSummaryType.Sum:
                                for (var _i = 0, sums_1 = sums; _i < sums_1.length; _i++) {
                                    var val = sums_1[_i];
                                    if (val == null || DBNull.sti.equals(val))
                                        continue;
                                    isNull = false;
                                    if (this.isAllowConvertToDecimal(value))
                                        value += this.convertToDecimal(val);
                                }
                                if (isNull)
                                    return this.crossTab.emptyValue;
                                return value;
                            // Max
                            case Core.StiSummaryType.Max:
                                // MaxDate
                                if (sums != null && sums.length > 0 && this.isDateTime(sums)) {
                                    var valueProcessed = false;
                                    var maximum = null;
                                    var indexOfSelectedValue = -1;
                                    var index = 0;
                                    for (var _a = 0, sums_2 = sums; _a < sums_2.length; _a++) {
                                        var val = sums_2[_a];
                                        if (val == null || DBNull.sti.equals(val))
                                            continue;
                                        isNull = false;
                                        // DateTime
                                        if (val.sti.is(DateTime)) {
                                            var dateTimeValue = val;
                                            if (valueProcessed) {
                                                if (maximum < dateTimeValue) {
                                                    maximum = dateTimeValue;
                                                    indexOfSelectedValue = index;
                                                }
                                            }
                                            else {
                                                maximum = dateTimeValue;
                                                valueProcessed = true;
                                                indexOfSelectedValue = 0;
                                            }
                                        }
                                        // DateTime?
                                        /*if (val.sti.is(DateTime ?)) {
                                            let dateTimeValue: DateTime? = <DateTime?>val;
                                            if (valueProcessed) {
                                                if (maximum < dateTimeValue) {
                                                    maximum = dateTimeValue;
                                                    indexOfSelectedValue = index;
                                                }
                                            }
                                            else {
                                                maximum = dateTimeValue;
                                                valueProcessed = true;
                                                indexOfSelectedValue = 0;
                                            }
                                        }*/
                                        index++;
                                    }
                                    crossSummary.indexOfSelectValue = indexOfSelectedValue;
                                    if (isNull)
                                        return this.crossTab.emptyValue;
                                    if (valueProcessed)
                                        return maximum;
                                    else
                                        return null;
                                }
                                else {
                                    var indexOfSelectedValue = -1;
                                    var index = 0;
                                    for (var _b = 0, sums_3 = sums; _b < sums_3.length; _b++) {
                                        var val = sums_3[_b];
                                        if (val == null || DBNull.sti.equals(val))
                                            continue;
                                        isNull = false;
                                        if (index == 0) {
                                            if (this.isAllowConvertToDecimal(val)) {
                                                value = this.convertToDecimal(val);
                                                indexOfSelectedValue = index;
                                            }
                                        }
                                        else {
                                            if (this.isAllowConvertToDecimal(val)) {
                                                var val2 = this.convertToDecimal(val);
                                                if (value < val2) {
                                                    value = val2;
                                                    indexOfSelectedValue = index;
                                                }
                                            }
                                        }
                                        index++;
                                    }
                                    crossSummary.indexOfSelectValue = indexOfSelectedValue;
                                    if (isNull)
                                        return this.crossTab.emptyValue;
                                    return value;
                                }
                            // Min
                            case Core.StiSummaryType.Min:
                                // MinDate
                                if (sums != null && sums.length > 0 && this.isDateTime(sums)) {
                                    var valueProcessed = false;
                                    var minimum = null;
                                    var indexOfSelectedValue = -1;
                                    var index = 0;
                                    for (var _c = 0, sums_4 = sums; _c < sums_4.length; _c++) {
                                        var val = sums_4[_c];
                                        if (val == null || DBNull.sti.equals(val))
                                            continue;
                                        isNull = false;
                                        // DateTime
                                        if (val.sti.is(DateTime)) {
                                            var dateTimeValue = val;
                                            if (valueProcessed) {
                                                if (minimum > dateTimeValue) {
                                                    minimum = dateTimeValue;
                                                    indexOfSelectedValue = index;
                                                }
                                            }
                                            else {
                                                minimum = dateTimeValue;
                                                valueProcessed = true;
                                                indexOfSelectedValue = 0;
                                            }
                                        }
                                        // DateTime?
                                        /*if (val.sti.is(DateTime ?)) {
                                            let dateTimeValue: DateTime? = <DateTime?>val;
                                            if (valueProcessed) {
                                                if (minimum > dateTimeValue) {
                                                    minimum = dateTimeValue;
                                                    indexOfSelectedValue = index;
                                                }
                                            }
                                            else {
                                                minimum = dateTimeValue;
                                                valueProcessed = true;
                                                indexOfSelectedValue = 0;
                                            }
                                        }*/
                                        index++;
                                    }
                                    crossSummary.indexOfSelectValue = indexOfSelectedValue;
                                    if (isNull)
                                        return this.crossTab.emptyValue;
                                    if (valueProcessed)
                                        return minimum;
                                    else
                                        return null;
                                }
                                else {
                                    var index2 = 0;
                                    var indexOfSelectedValue = -1;
                                    for (var _d = 0, sums_5 = sums; _d < sums_5.length; _d++) {
                                        var val = sums_5[_d];
                                        if (val == null || DBNull.sti.equals(val))
                                            continue;
                                        isNull = false;
                                        if (index2 == 0) {
                                            if (this.isAllowConvertToDecimal(val)) {
                                                value = this.convertToDecimal(val);
                                                indexOfSelectedValue = 0;
                                            }
                                        }
                                        else {
                                            if (this.isAllowConvertToDecimal(val)) {
                                                var val2 = this.convertToDecimal(val);
                                                if (value > val2) {
                                                    value = val2;
                                                    indexOfSelectedValue = index2;
                                                }
                                            }
                                        }
                                        index2++;
                                    }
                                    crossSummary.indexOfSelectValue = indexOfSelectedValue;
                                    if (isNull)
                                        return this.crossTab.emptyValue;
                                    return value;
                                }
                            // Count
                            case Core.StiSummaryType.Count:
                                if (sums == null || sums.length == 0)
                                    return 0;
                                var countOfValues = 0;
                                for (var _e = 0, sums_6 = sums; _e < sums_6.length; _e++) {
                                    var val = sums_6[_e];
                                    isNull = false;
                                    var valueDecimal = 0;
                                    if (this.isAllowConvertToDecimal(val)) {
                                        valueDecimal = this.convertToDecimal(val);
                                    }
                                    if (summaryValues == Core.StiSummaryValues.AllValues)
                                        countOfValues++;
                                    if (summaryValues == Core.StiSummaryValues.SkipNulls && val != null)
                                        countOfValues++;
                                    if (summaryValues == Core.StiSummaryValues.SkipZerosAndNulls && val != null && valueDecimal != 0)
                                        countOfValues++;
                                }
                                if (isNull)
                                    return this.crossTab.emptyValue;
                                return countOfValues;
                            // Average
                            case Core.StiSummaryType.Average:
                                // MinDate
                                if (sums != null && sums.length > 0 && this.isDateTime(sums)) {
                                    var avgValue = 0;
                                    var count2 = 0;
                                    for (var _f = 0, sums_7 = sums; _f < sums_7.length; _f++) {
                                        var val = sums_7[_f];
                                        if (val == null || DBNull.sti.equals(val))
                                            continue;
                                        isNull = false;
                                        // DateTime
                                        if (val.sti.is(DateTime)) {
                                            var dateTimeValue = val;
                                            avgValue += dateTimeValue.ticks;
                                            count2++;
                                        }
                                        // DateTime?
                                        /*if (val.sti.is(DateTime ?) && val != null) {
                                            let dateTimeValue: DateTime? = <DateTime?>val;
                                            avgValue += dateTimeValue.Value.Ticks;
                                            count2++;
                                        }*/
                                    }
                                    if (count2 == 0)
                                        return null;
                                    if (isNull)
                                        return this.crossTab.emptyValue;
                                    return new DateTime(avgValue / count2);
                                }
                                else {
                                    if (sums == null || sums.length == 0)
                                        return 0;
                                    var countOfValues2 = 0;
                                    for (var _g = 0, sums_8 = sums; _g < sums_8.length; _g++) {
                                        var val = sums_8[_g];
                                        if (val == null || DBNull.sti.equals(val))
                                            continue;
                                        isNull = false;
                                        var valueDecimal = 0;
                                        if (this.isAllowConvertToDecimal(val)) {
                                            valueDecimal = this.convertToDecimal(val);
                                            value += valueDecimal;
                                        }
                                        if (summaryValues == Core.StiSummaryValues.AllValues)
                                            countOfValues2++;
                                        if (summaryValues == Core.StiSummaryValues.SkipNulls && val != null)
                                            countOfValues2++;
                                        if (summaryValues == Core.StiSummaryValues.SkipZerosAndNulls && val != null && valueDecimal != 0)
                                            countOfValues2++;
                                    }
                                    if (countOfValues2 == 0)
                                        return 0;
                                    if (isNull)
                                        return this.crossTab.emptyValue;
                                    return Math.round2(value / countOfValues2, 4);
                                }
                            // CountDistinct
                            case Core.StiSummaryType.CountDistinct:
                                if (sums == null || sums.length == 0)
                                    return 0;
                                var values = new Hashtable();
                                var count = 0;
                                var nullProcessed = false;
                                for (var _h = 0, sums_9 = sums; _h < sums_9.length; _h++) {
                                    var val = sums_9[_h];
                                    isNull = false;
                                    var valueDecimal = 0;
                                    var converted = false;
                                    if (this.isAllowConvertToDecimal(val)) {
                                        valueDecimal = this.convertToDecimal(val);
                                        converted = true;
                                    }
                                    if (val == null) {
                                        if (summaryValues == Core.StiSummaryValues.AllValues) {
                                            if (!nullProcessed) {
                                                nullProcessed = true;
                                                count++;
                                            }
                                        }
                                    }
                                    else if (values.get(val) == null) {
                                        if (valueDecimal == 0 && converted && summaryValues == Core.StiSummaryValues.SkipZerosAndNulls)
                                            continue;
                                        values.set(val, val);
                                        count++;
                                    }
                                }
                                if (isNull)
                                    return this.crossTab.emptyValue;
                                return count;
                        }
                        return value;
                    };
                    StiCross.prototype.copySummaries = function (left, top, emptyValue) {
                        var rowsArray = this.getRowsArray();
                        var colsArray = this.getColsArray();
                        // Prepare totals calculation
                        var sumsOnCell = Array.create(Array, this.colsHeaderHeight * this.oneCellSize);
                        for (var totalIndex = 0; totalIndex < sumsOnCell.length; totalIndex++) {
                            sumsOnCell[totalIndex] = [];
                        }
                        var rowIndex = 0;
                        var colIndex = 0;
                        for (var _i = 0, rowsArray_1 = rowsArray; _i < rowsArray_1.length; _i++) {
                            var row = rowsArray_1[_i];
                            // New Row - Clear totals calculatation
                            for (var totalIndex = 0; totalIndex < sumsOnCell.length; totalIndex++) {
                                sumsOnCell[totalIndex].clear();
                            }
                            colIndex = 0;
                            for (var _a = 0, colsArray_1 = colsArray; _a < colsArray_1.length; _a++) {
                                var col = colsArray_1[_a];
                                if (col.isTotal) {
                                    // IsTotal
                                    for (var sumIndex = 0; sumIndex < this.oneCellSize; sumIndex++) {
                                        var list = sumsOnCell[col.level * this.oneCellSize + sumIndex];
                                        var value = this.getSummary2(list, sumIndex, true);
                                        list.clear();
                                        var x = 0;
                                        var y = 0;
                                        if (this.summaryDirection == Core.StiSummaryDirection.UpToDown) {
                                            x = left + colIndex;
                                            y = top + rowIndex * this.oneCellSize + sumIndex;
                                        }
                                        else {
                                            x = left + colIndex * this.oneCellSize + sumIndex;
                                            y = top + rowIndex;
                                        }
                                        var summary = this.summaryContainer.getSummary(col, row, true);
                                        summary.sums[sumIndex].add(value);
                                        this.invokeEvents(this.sumFields.getByIndex(sumIndex));
                                        var cell = this.setCellValue(x, y, value, sumIndex, col.level, Core.StiFieldType.Column, this.sumFields.getByIndex(sumIndex).hyperlinkValue, this.sumFields.getByIndex(sumIndex).toolTipValue, this.sumFields.getByIndex(sumIndex).tagValue, this.sumFields.getByIndex(sumIndex).drillDownParameters);
                                        cell.summaryIndex = sumIndex;
                                        cell.isCrossSummary = true;
                                        if (this.sumFields.getByIndex(sumIndex).summary == Core.StiSummaryType.Image ||
                                            this.sumFields.getByIndex(sumIndex).summary == Core.StiSummaryType.None) {
                                            cell.value = null;
                                            cell.text = "";
                                        }
                                        // Calculate Percent
                                        var valueTotal = 0;
                                        if (cell.isNumeric && cell.value != null)
                                            valueTotal = cell.value.sti.toNumber();
                                        var showPercents = false;
                                        for (var index = x - 1; index >= 0; index--) {
                                            var cell2 = this.cells[index][y];
                                            if (cell2.field != null && !(cell2.field.sti.is(CrossTab.StiCrossSummary)))
                                                break;
                                            var value2 = 0;
                                            if (cell2.isNumeric) {
                                                value2 = cell2.value.sti.toNumber();
                                            }
                                            if (valueTotal != 0)
                                                value2 = Math.round2(value2 / valueTotal * 100, 2);
                                            else
                                                value2 = 0;
                                            if (cell2.isNumeric && cell2.field != null && cell2.field.sti.is(CrossTab.StiCrossSummary) &&
                                                cell2.field.showPercents) {
                                                cell2.value = value2;
                                                cell2.text = StiString.format("{0}%", value2);
                                                showPercents = true;
                                            }
                                        }
                                        if (showPercents) {
                                            if (cell.field != null && cell.field.sti.is(CrossTab.StiCrossTotal))
                                                cell.text = "100%";
                                        }
                                        if (this.sumFields.getByIndex(sumIndex).useStyleOfSummaryInColumnTotal) {
                                            this.setCellField(x, y, this.sumFields.getByIndex(sumIndex).clone().sti.as(CrossTab.StiCrossField));
                                        }
                                    }
                                }
                                else {
                                    // Create cell
                                    var summary = this.summaryContainer.getSummary(col, row, false);
                                    var sums = this.copySummary(summary, left, top, colIndex, rowIndex, true, false, emptyValue);
                                    // Calc totals
                                    for (var totalIndex = 0; totalIndex < this.colsHeaderHeight; totalIndex++) {
                                        for (var sumIndex = 0; sumIndex < this.oneCellSize; sumIndex++) {
                                            var list = sumsOnCell[totalIndex * this.oneCellSize + sumIndex];
                                            list.add(sums[sumIndex]);
                                        }
                                    }
                                }
                                colIndex++;
                            }
                            rowIndex++;
                        }
                        // Vert totals calculation
                        // Prepare totals calculation
                        sumsOnCell = Array.create(Array, this.rowsHeaderWidth * this.oneCellSize);
                        for (var totalIndex = 0; totalIndex < sumsOnCell.length; totalIndex++) {
                            sumsOnCell[totalIndex] = [];
                        }
                        colIndex = 0;
                        for (var _b = 0, colsArray_2 = colsArray; _b < colsArray_2.length; _b++) {
                            var col = colsArray_2[_b];
                            // New Col - Clear totals calculatation
                            for (var totalIndex = 0; totalIndex < this.rowsHeaderWidth * this.oneCellSize; totalIndex++) {
                                sumsOnCell[totalIndex].clear();
                            }
                            rowIndex = 0;
                            for (var _c = 0, rowsArray_2 = rowsArray; _c < rowsArray_2.length; _c++) {
                                var row = rowsArray_2[_c];
                                if (row.isTotal) {
                                    // IsTotal
                                    for (var sumIndex = 0; sumIndex < this.oneCellSize; sumIndex++) {
                                        var list = sumsOnCell[row.level * this.oneCellSize + sumIndex];
                                        var isMegaTotal = colIndex == colsArray.length - 1 && rowIndex == rowsArray.length - 1;
                                        var value = this.getSummary2(list, sumIndex, true, isMegaTotal);
                                        list.clear();
                                        var x = 0;
                                        var y = 0;
                                        if (this.summaryDirection == Core.StiSummaryDirection.UpToDown) {
                                            x = left + colIndex;
                                            y = top + rowIndex * this.oneCellSize + sumIndex;
                                        }
                                        else {
                                            x = left + colIndex * this.oneCellSize + sumIndex;
                                            y = top + rowIndex;
                                        }
                                        this.invokeEvents(this.sumFields.getByIndex(sumIndex));
                                        var cell = this.setCellValue(x, y, value, sumIndex, row.level, Core.StiFieldType.Row, this.sumFields.getByIndex(sumIndex).hyperlinkValue, this.sumFields.getByIndex(sumIndex).toolTipValue, this.sumFields.getByIndex(sumIndex).tagValue, this.sumFields.getByIndex(sumIndex).drillDownParameters);
                                        cell.summaryIndex = sumIndex;
                                        if (this.sumFields.getByIndex(sumIndex).summary == Core.StiSummaryType.Image ||
                                            this.sumFields.getByIndex(sumIndex).summary == Core.StiSummaryType.None) {
                                            cell.value = null;
                                            cell.text = "";
                                        }
                                        if (this.sumFields.getByIndex(sumIndex).useStyleOfSummaryInRowTotal)
                                            this.setCellField(x, y, this.sumFields.getByIndex(sumIndex).clone().sti.as(CrossTab.StiCrossField));
                                    }
                                }
                                else {
                                    // Create cell
                                    var summary = this.summaryContainer.getSummary(col, row, false);
                                    // fixed by Nikolay: grandTotal передаётся корректно из другой точки, иначе портятся результаты общей суммы по агрегаторам
                                    // это окончательный вариант - именно так считает эксель
                                    var sums = this.copySummary(summary, left, top, colIndex, rowIndex, false, colsArray.indexOf(col) == colsArray.length - 1, emptyValue);
                                    // Calc totals
                                    for (var totalIndex = 0; totalIndex < this.rowsHeaderWidth; totalIndex++) {
                                        for (var sumIndex = 0; sumIndex < this.oneCellSize; sumIndex++) {
                                            var list = sumsOnCell[totalIndex * this.oneCellSize + sumIndex];
                                            list.add(sums[sumIndex]);
                                        }
                                    }
                                }
                                rowIndex++;
                            }
                            colIndex++;
                        }
                    };
                    StiCross.prototype.copySummary = function (summary, left, top, colIndex, rowIndex, setValue, grandTotal, emptyValue) {
                        var sumsOnCell = Array.create(Object, this.oneCellSize);
                        for (var calcIndex = 0; calcIndex < this.oneCellSize; calcIndex++) {
                            var value = emptyValue;
                            if (summary != null) {
                                value = this.getSummary(summary, calcIndex, grandTotal);
                                sumsOnCell[calcIndex] = value;
                            }
                            var x = 0;
                            var y = 0;
                            if (this.summaryDirection == Core.StiSummaryDirection.UpToDown) {
                                x = left + colIndex;
                                y = top + rowIndex * this.oneCellSize + calcIndex;
                            }
                            else {
                                x = left + colIndex * this.oneCellSize + calcIndex;
                                y = top + rowIndex;
                            }
                            var hyperlinkValue = summary != null ? summary.hyperlinkValues[calcIndex] : null;
                            var toolTipValue = summary != null ? summary.toolTipValues[calcIndex] : null;
                            var tagValue = summary != null ? summary.tagValues[calcIndex] : null;
                            var drillDownParameters = (summary != null && summary.drillDownParameters != null)
                                ? summary.drillDownParameters[calcIndex]
                                : null;
                            if (!setValue || x >= this.widths.length || y >= this.heights.length)
                                continue;
                            var cell = this.setCellValue(x, y, value, calcIndex, 0, Core.StiFieldType.Cell, hyperlinkValue, toolTipValue, tagValue, drillDownParameters);
                            cell.summaryIndex = calcIndex;
                        }
                        return sumsOnCell;
                    };
                    StiCross.prototype.getSummary = function (summary, calcIndex, grandTotal) {
                        var sums = [];
                        for (var _i = 0, _a = summary.sums[calcIndex]; _i < _a.length; _i++) {
                            var val = _a[_i];
                            sums.add(val);
                        }
                        return this.getSummaryResult(sums, calcIndex, grandTotal);
                    };
                    StiCross.prototype.isHideZeros = function (value) {
                        return value != null && Type.isNumericType(Type.getType(value)) && StiValueHelper.tryToNumber(value) == 0;
                    };
                    StiCross.prototype.isDateTime = function (list) {
                        for (var _i = 0, list_2 = list; _i < list_2.length; _i++) {
                            var value = list_2[_i];
                            if (value != null && value.sti.is(DateTime))
                                return true;
                            // if (value.sti.is(DateTime ?)) return true;
                        }
                        return false;
                    };
                    StiCross.convertValueToString = function (value, field) {
                        if (value == null)
                            return "";
                        if (value.sti.is(Number) && value == 0 && field.hideZeros)
                            return "";
                        if (value.sti.is(Number))
                            return field.textFormat.format(value);
                        if (value.sti.is(DateTime))
                            return field.textFormat.format(value);
                        return value.toString();
                    };
                    StiCross.prototype.setCellValue = function (x, y, value, calcIndex, level, fieldType, hyperlinkValue, toolTipValue, tagValue, drillDownParameters) {
                        switch (fieldType) {
                            case Core.StiFieldType.Column: {
                                var field = this.getColumnTotalCell(level, calcIndex);
                                var str = StiCross.convertValueToString(value, field);
                                var cell = this.setCell(x, y, 1, 1, str, value, field, value != null ? value.sti.is(Number) : false, hyperlinkValue, toolTipValue, tagValue, drillDownParameters);
                                StiCross.checkNegativeColor(value, field, cell);
                                return cell;
                            }
                            case Core.StiFieldType.Row: {
                                var field = this.getRowTotalCell(level, calcIndex);
                                var str = StiCross.convertValueToString(value, field);
                                var cell = this.setCell(x, y, 1, 1, str, value, field, value != null ? value.sti.is(Number) : false, hyperlinkValue, toolTipValue, tagValue, drillDownParameters);
                                StiCross.checkNegativeColor(value, field, cell);
                                return cell;
                            }
                            case Core.StiFieldType.Cell: {
                                var field = this.sumFields.getByIndex(calcIndex);
                                var str = StiCross.convertValueToString(value, field);
                                var cell = this.setCell(x, y, 1, 1, str, value, field, value != null ? value.sti.is(Number) : false, hyperlinkValue, toolTipValue, tagValue, drillDownParameters);
                                StiCross.checkNegativeColor(value, field, cell);
                                return cell;
                            }
                        }
                        return null;
                    };
                    StiCross.checkNegativeColor = function (value, field3, cell) {
                        if (Stimulsoft.Report.Components.TextFormats.StiNegativeColorChecker.isNegativeInRed(field3.textFormat)) {
                            var valueDecimal = StiValueHelper.tryToNullableNumber(value);
                            cell.isNegativeColor = valueDecimal != null && valueDecimal < 0;
                        }
                    };
                    StiCross.prototype.getColumnTotalCell = function (level, calcIndex) {
                        var column = this.columnsCell.get(level * this.oneCellSize + calcIndex);
                        if (column == null) {
                            var crossHeader = this.colFields.getByIndex(level).sti.as(CrossTab.StiCrossHeader);
                            column = crossHeader.total.clone(true).sti.as(CrossTab.StiCrossField);
                            this.columnsCell.set(level * this.oneCellSize + calcIndex, column);
                            // Change in 2008.1.264 from 12 August 2008
                            // Commented to allow right border
                            // column.Border =          ((StiCrossField)SumFields[calcIndex]).Border.Clone() as StiBorder;
                            column.horAlignment = this.sumFields.getByIndex(calcIndex).horAlignment;
                            column.vertAlignment = this.sumFields.getByIndex(calcIndex).vertAlignment;
                            column.textFormat = this.sumFields.getByIndex(calcIndex).textFormat.clone().sti.as(StiFormatService);
                        }
                        return column;
                    };
                    StiCross.prototype.getRowTotalCell = function (level, calcIndex) {
                        var row = this.rowsCell.get(level * this.oneCellSize + calcIndex);
                        if (row == null) {
                            row = this.rowFields.getByIndex(level).total.clone(true).sti.as(CrossTab.StiCrossField);
                            this.rowsCell.set(level * this.oneCellSize + calcIndex, row);
                            // Change in 2008.1.264 from 12 August 2008
                            // Commented to allow bottom border
                            // row.Border =     ((StiCrossField)SumFields[calcIndex]).Border.Clone() as StiBorder;
                            row.horAlignment = this.sumFields.getByIndex(calcIndex).horAlignment;
                            row.vertAlignment = this.sumFields.getByIndex(calcIndex).vertAlignment;
                            row.textFormat = this.sumFields.getByIndex(calcIndex).textFormat.clone().sti.as(StiFormatService);
                        }
                        return row;
                    };
                    StiCross.prototype.getRowsArray = function () {
                        var array = [];
                        this.getRowsArray2(this.rows, array);
                        return array;
                    };
                    StiCross.prototype.getRowsArray2 = function (rows, array) {
                        for (var _i = 0, _a = rows.list; _i < _a.length; _i++) {
                            var row = _a[_i];
                            if (row.rows.count == 0)
                                array.add(row);
                            this.getRowsArray2(row.rows, array);
                        }
                    };
                    StiCross.prototype.getColsArray = function () {
                        var array = [];
                        this.getColsArray2(this.cols, array);
                        return array;
                    };
                    StiCross.prototype.getColsArray2 = function (cols, array) {
                        for (var _i = 0, _a = cols.list; _i < _a.length; _i++) {
                            var col = _a[_i];
                            if (col.cols.count == 0)
                                array.add(col);
                            this.getColsArray2(col.cols, array);
                        }
                    };
                    StiCross.prototype.getRowsHeaderWidth = function () {
                        if (this.isRowsEmpty)
                            return 0;
                        return this.getRowsHeaderWidth2(this.rows);
                    };
                    StiCross.prototype.getRowsHeaderWidth2 = function (rows) {
                        var width = 0;
                        while (rows.count > 0) {
                            width++;
                            rows = rows.getByIndex(0).rows;
                        }
                        return width;
                    };
                    StiCross.prototype.getColsHeaderHeight = function () {
                        if (this.isColsEmpty)
                            return 0;
                        return this.getColsHeaderHeight2(this.cols);
                    };
                    StiCross.prototype.getColsHeaderHeight2 = function (cols) {
                        var height = 0;
                        while (cols.count > 0) {
                            height++;
                            cols = cols.getByIndex(0).cols;
                        }
                        return height;
                    };
                    StiCross.prototype.getRowsHeight = function (rows, maxLevel, curLevel) {
                        if (rows === void 0) { rows = this.rows; }
                        if (maxLevel === void 0) { maxLevel = this.getRowsHeaderWidth(); }
                        if (curLevel === void 0) { curLevel = 0; }
                        var rowHeight = 0;
                        for (var _i = 0, _a = rows.list; _i < _a.length; _i++) {
                            var row = _a[_i];
                            rowHeight += this.getRowsHeight(row.rows, maxLevel, curLevel + 1);
                            if (curLevel == maxLevel - 1) {
                                rowHeight += this.oneCellHeight;
                            }
                        }
                        return rowHeight;
                    };
                    StiCross.prototype.getColsWidth = function (cols, maxLevel, curLevel) {
                        if (cols === void 0) { cols = this.cols; }
                        if (maxLevel === void 0) { maxLevel = this.getColsHeaderHeight(); }
                        if (curLevel === void 0) { curLevel = 0; }
                        var colWidth = 0;
                        for (var _i = 0, _a = cols.list; _i < _a.length; _i++) {
                            var col = _a[_i];
                            colWidth += this.getColsWidth(col.cols, maxLevel, curLevel + 1);
                            if (curLevel == maxLevel - 1) {
                                colWidth += this.oneCellWidth;
                            }
                        }
                        return colWidth;
                    };
                    // Enumerate Rows and Cols
                    StiCross.prototype.enumerateRows = function (rows, level) {
                        var crossRow = this.rowFields.getByIndex(level).sti.as(CrossTab.StiCrossRow);
                        var separator = crossRow.enumeratorSeparator;
                        var index = 0;
                        for (var _i = 0, _a = rows.list; _i < _a.length; _i++) {
                            var row = _a[_i];
                            if (row.rows != null && row.rows.count > 0)
                                this.enumerateRows(row.rows, level + 1);
                            if (crossRow.enumeratorType != Core.StiEnumeratorType.None) {
                                index++;
                                var numberr = null;
                                if (crossRow.enumeratorType == Core.StiEnumeratorType.Arabic)
                                    numberr = index.toString();
                                else if (crossRow.enumeratorType == Core.StiEnumeratorType.ABC)
                                    numberr = Report.Func.Convert.toABC(index);
                                else
                                    numberr = Report.Func.Convert.toRoman(index);
                                row.displayValue = StiString.format("{0}{1}{2}", numberr, separator, row.displayValue);
                            }
                        }
                    };
                    StiCross.prototype.enumerateColumns = function (columns, level) {
                        var crossColumn = this.colFields.getByIndex(level).sti.as(CrossTab.StiCrossColumn);
                        var separator = crossColumn.enumeratorSeparator;
                        var index = 0;
                        for (var _i = 0, _a = columns.list; _i < _a.length; _i++) {
                            var column = _a[_i];
                            if (column.cols != null && column.cols.count > 0)
                                this.enumerateColumns(column.cols, level + 1);
                            if (crossColumn.enumeratorType != Core.StiEnumeratorType.None) {
                                index++;
                                var numberr = null;
                                if (crossColumn.enumeratorType == Core.StiEnumeratorType.Arabic)
                                    numberr = index.toString();
                                else if (crossColumn.enumeratorType == Core.StiEnumeratorType.ABC)
                                    numberr = Report.Func.Convert.toABC(index);
                                else
                                    numberr = Report.Func.Convert.toRoman(index);
                                column.displayValue = StiString.format("{0}{1}{2}", numberr, separator, column.displayValue);
                            }
                        }
                    };
                    StiCross.prototype.checkSeparators = function () {
                        var newColCount = 0;
                        var findedCells = new Hashtable();
                        var lengthOfColumn = new Hashtable();
                        var needProcess = false;
                        // Check for separator |
                        for (var colIndex = 0; colIndex < this.colCount; colIndex++) {
                            var separatorCount = 1;
                            for (var rowIndex = 0; rowIndex < this.rowCount; rowIndex++) {
                                var cell = this.cells[colIndex][rowIndex];
                                if (cell.parentCell == cell && cell.text.sti.contains("#|#") && cell.width == 1) {
                                    var count = 1;
                                    for (var index2 = 0; index2 < cell.text.length; index2++) {
                                        if (index2 < cell.text.length - 3 &&
                                            cell.text[index2] == "#" &&
                                            cell.text[index2 + 1] == "|" &&
                                            cell.text[index2 + 2] == "#") {
                                            findedCells.set(cell, cell);
                                            needProcess = true;
                                            count++;
                                        }
                                    }
                                    separatorCount = Math.max(separatorCount, count);
                                }
                            }
                            lengthOfColumn[colIndex] = separatorCount;
                            newColCount += separatorCount;
                        }
                        // If we need to change amount of columns
                        if (newColCount > this.colCount || needProcess) {
                            var oldColCount = this.colCount;
                            var oldCells = this.cells;
                            this.init(newColCount, this.rowCount);
                            var newColIndex = 0;
                            for (var colIndex = 0; colIndex < oldColCount; colIndex++) {
                                var length_1 = Math.trunc(lengthOfColumn.get(colIndex));
                                var separatorCount = 1;
                                for (var rowIndex = 0; rowIndex < this.rowCount; rowIndex++) {
                                    var oldCell = oldCells[colIndex][rowIndex];
                                    // If need process cell
                                    if (findedCells.get(oldCell) != null && oldCell.parentCell == oldCell) {
                                        var strs = oldCell.text.split("#|#");
                                        separatorCount = Math.max(separatorCount, strs.length + 1);
                                        oldCell.text = strs[0];
                                        this.cells[newColIndex][rowIndex] = oldCell;
                                        for (var index2 = 1; index2 < strs.length; index2++) {
                                            var copyCell = oldCell.clone().sti.as(Core.StiCell);
                                            this.cells[newColIndex + index2][rowIndex] = copyCell;
                                            copyCell.text = strs[index2];
                                        }
                                    }
                                    else {
                                        oldCell.parentCell.width += length_1 - 1;
                                        this.cells[newColIndex][rowIndex] = oldCell;
                                    }
                                }
                                newColIndex += length_1;
                            }
                        }
                    };
                    StiCross.prototype.create = function (table, report, direction, emptyValue) {
                        this.summaryDirection = direction;
                        this.report = report;
                        this.oneCellSize = this.sumFields.count;
                        this.oneCellWidth = this.summaryDirection == Core.StiSummaryDirection.LeftToRight ? this.oneCellSize : 1;
                        this.oneCellHeight = this.summaryDirection == Core.StiSummaryDirection.UpToDown ? this.oneCellSize : 1;
                        this.summaryContainer = new Core.StiSummaryContainer(this.oneCellSize);
                        this.rows.clear();
                        this.cols.clear();
                        this.calculateDataTable(table);
                        this.calculateTopN();
                        this.sortRows();
                        this.sortCols();
                        if (this.rows.count > 0)
                            this.enumerateRows(this.rows, 0);
                        if (this.cols.count > 0)
                            this.enumerateColumns(this.cols, 0);
                        this.createRowTotals();
                        this.createColTotals();
                        // Init parameters
                        this.colsHeaderHeight = this.getColsHeaderHeight();
                        this.rowsHeaderWidth = this.getRowsHeaderWidth();
                        if (this.isSummarySubHeadersPresent) {
                            if (direction == Core.StiSummaryDirection.LeftToRight)
                                this.colsHeaderHeight++;
                            else
                                this.rowsHeaderWidth++;
                        }
                        this.colsWidth = this.getColsWidth();
                        this.rowsHeight = this.getRowsHeight();
                        var totalCellsWidth = this.colsWidth + this.rowsHeaderWidth;
                        var totalCellsHeight = this.rowsHeight + this.colsHeaderHeight;
                        if (this.isRowsEmpty)
                            totalCellsHeight += this.oneCellHeight;
                        if (this.isColsEmpty)
                            totalCellsWidth += this.oneCellWidth;
                        this.widthCorrection = 0;
                        this.heightCorrection = 0;
                        if (this.isColsEmpty && this.isSummaryPresent)
                            this.heightCorrection = 1;
                        if (this.isRowsEmpty && this.isSummaryPresent)
                            this.widthCorrection = 1;
                        if (this.isRowsEmpty && !this.isColsEmpty && this.isSummariesEmpty)
                            this.widthCorrection = 1;
                        if (this.isTopLinePresent)
                            this.heightCorrection++;
                        _super.prototype.init.call(this, totalCellsWidth + this.widthCorrection, totalCellsHeight + this.heightCorrection);
                        if (this.isRowsEmpty && this.isColsEmpty)
                            return;
                        // Create Col Titles
                        var index = 0;
                        for (var _i = 0, _a = this.colFields.toCast(); _i < _a.length; _i++) {
                            var col = _a[_i];
                            var currTitle = null;
                            for (var _b = 0, _c = this.colTitleFields.toCast(); _b < _c.length; _b++) {
                                var title = _c[_b];
                                if (title.typeOfComponent == "Col:" + col.name) {
                                    currTitle = title;
                                    break;
                                }
                            }
                            if (currTitle != null && currTitle.isEnabled) {
                                var cellHeight = 1;
                                var cellWidth = Math.max(this.rowsHeaderWidth, 1);
                                this.invokeEvents(currTitle);
                                this.setCell(0, index++, cellWidth, cellHeight, currTitle.textValue == null ? currTitle.getTextInternal() : currTitle.textValue, emptyValue, currTitle, false, currTitle.hyperlinkValue, currTitle.toolTipValue, currTitle.tagValue, currTitle.drillDownParameters);
                            }
                        }
                        // Create Row Titles
                        var isRowTitlePresent = this.isRowTitlePresent;
                        index = 0;
                        for (var _d = 0, _e = this.rowFields.toCast(); _d < _e.length; _d++) {
                            var row = _e[_d];
                            var currTitle = null;
                            for (var _f = 0, _g = this.rowTitleFields.toCast(); _f < _g.length; _f++) {
                                var title = _g[_f];
                                if (title.typeOfComponent == "Row:" + row.name) {
                                    currTitle = title;
                                    break;
                                }
                            }
                            if (currTitle != null && isRowTitlePresent) {
                                var cellWidth = 1;
                                // 2014.05.29 Строка закомментирована для исправления ошибки "смещение заголовка столбца при нескольких суммари".
                                // if (IsSummarySubHeadersPresent && direction != StiSummaryDirection.LeftToRight) cellWidth++;
                                var cellHeight = Math.max(this.colsHeaderHeight, 1);
                                var top_1 = this.isTopLinePresent ? 1 : 0;
                                this.invokeEvents(currTitle);
                                // Fix- 2016.07.25
                                // Increase height when we have more than one sum fields and don't have columns
                                if (direction == Core.StiSummaryDirection.LeftToRight && this.isColsEmpty && this.sumFields.count > 1) {
                                    cellHeight++;
                                }
                                this.setCell(index++, top_1, cellWidth, cellHeight, currTitle.textValue == null ? currTitle.getTextInternal() : currTitle.textValue, emptyValue, currTitle, false, currTitle.hyperlinkValue, currTitle.toolTipValue, currTitle.tagValue, currTitle.drillDownParameters);
                            }
                        }
                        if (this.isSummarySubHeadersPresent) {
                            // LeftToRight
                            if (direction == Core.StiSummaryDirection.LeftToRight) {
                                var top_2 = this.colsHeaderHeight + this.heightCorrection - 1;
                                index = this.rowsHeaderWidth + this.widthCorrection;
                                var summaryIndex = 0;
                                var columnCount = this.colsWidth == 0 ? this.sumFields.count : this.colsWidth;
                                for (var index2 = 0; index2 < columnCount; index2++) {
                                    var header = this.sumHeaderFields.getByIndex(summaryIndex).sti.as(CrossTab.StiCrossSummaryHeader);
                                    if (!this.designTime) {
                                        var args = new StiGetValueEventArgs();
                                        header.invokeGetValue(header, args);
                                        header.setTextInternal(args.value);
                                    }
                                    this.invokeEvents(header);
                                    this.setCell(index, top_2, 1, 1, header.textValue == null ? header.getTextInternal() : header.textValue, emptyValue, header, false, header.hyperlinkValue, header.toolTipValue, header.tagValue, header.drillDownParameters);
                                    index++;
                                    summaryIndex++;
                                    if (summaryIndex == this.sumHeaderFields.count)
                                        summaryIndex = 0;
                                }
                            }
                            // UpToDown
                            else {
                                var left = this.rowsHeaderWidth + this.widthCorrection - 1;
                                index = this.colsHeaderHeight + this.heightCorrection;
                                var step = 0;
                                var count = 0;
                                if (this.rowsHeight == 0)
                                    count = this.sumHeaderFields.count;
                                else
                                    count = this.rowsHeight;
                                // for (int index2 = 0; index2 < rowsHeight; index2++)
                                for (var index2 = 0; index2 < count; index2++) {
                                    var header = this.sumHeaderFields.getByIndex(step).sti.as(CrossTab.StiCrossSummaryHeader);
                                    if (!this.designTime) {
                                        var args = new StiGetValueEventArgs();
                                        header.invokeGetValue(header, args);
                                        header.setTextInternal(args.value);
                                    }
                                    this.invokeEvents(header);
                                    this.setCell(left, index, 1, 1, header.textValue == null ? header.getTextInternal() : header.textValue, emptyValue, header, false, header.hyperlinkValue, header.toolTipValue, header.tagValue, header.drillDownParameters);
                                    index++;
                                    step++;
                                    if (step == this.sumHeaderFields.count)
                                        step = 0;
                                }
                            }
                        }
                        // Create Top Line
                        if (this.isTopLinePresent) {
                            if (this.isLeftTopLinePresent) {
                                this.invokeEvents(this.leftCrossTitle);
                                this.setCell(0, 0, this.rowsHeaderWidth, 1, this.leftCrossTitle.textValue == null ? this.leftCrossTitle.getTextInternal() : this.leftCrossTitle.textValue, emptyValue, this.leftCrossTitle, false, this.leftCrossTitle.hyperlinkValue, this.leftCrossTitle.toolTipValue, this.leftCrossTitle.tagValue, this.leftCrossTitle.drillDownParameters);
                            }
                            if (this.isRightTopLinePresent && totalCellsWidth - this.rowsHeaderWidth > 0) {
                                this.invokeEvents(this.rightCrossTitle);
                                this.setCell(this.rowsHeaderWidth, 0, totalCellsWidth - this.rowsHeaderWidth, 1, this.rightCrossTitle.textValue == null ? this.rightCrossTitle.getTextInternal() : this.rightCrossTitle.textValue, emptyValue, this.rightCrossTitle, false, this.rightCrossTitle.hyperlinkValue, this.rightCrossTitle.toolTipValue, this.rightCrossTitle.tagValue, this.rightCrossTitle.drillDownParameters);
                            }
                        }
                        // Create Summary Title
                        if (this.summaryCrossTitle != null) {
                            if (this.isColsEmpty) {
                                this.invokeEvents(this.summaryCrossTitle);
                                this.setCell(this.rowsHeaderWidth, 0, this.oneCellWidth, 1, this.summaryCrossTitle.textValue == null ? this.summaryCrossTitle.getTextInternal() : this.summaryCrossTitle.textValue, emptyValue, this.summaryCrossTitle, false, this.summaryCrossTitle.hyperlinkValue, this.summaryCrossTitle.toolTipValue, this.summaryCrossTitle.tagValue, this.summaryCrossTitle.drillDownParameters);
                            }
                            if (this.isRowsEmpty) {
                                this.invokeEvents(this.summaryCrossTitle);
                                var y = direction == Core.StiSummaryDirection.LeftToRight ? this.colsHeaderHeight - 1 : this.colsHeaderHeight;
                                var height = direction == Core.StiSummaryDirection.LeftToRight ? this.oneCellHeight + 1 : this.oneCellHeight;
                                this.setCell(0, y, 1, height, this.summaryCrossTitle.textValue == null ? this.summaryCrossTitle.getTextInternal() : this.summaryCrossTitle.textValue, emptyValue, this.summaryCrossTitle, false, this.summaryCrossTitle.hyperlinkValue, this.summaryCrossTitle.toolTipValue, this.summaryCrossTitle.tagValue, this.summaryCrossTitle.drillDownParameters);
                            }
                        }
                        var guid = { ref: "" };
                        if (!this.isRowsEmpty)
                            this.copyRows(this.rows, 0, this.colsHeaderHeight + this.heightCorrection, 0, emptyValue, this.colsWidth, guid);
                        if (!this.isColsEmpty)
                            this.copyCols(this.cols, this.rowsHeaderWidth + this.widthCorrection, this.heightCorrection, 0, emptyValue, this.rowsHeight, guid);
                        this.copySummaries(this.rowsHeaderWidth + this.widthCorrection, this.colsHeaderHeight + this.heightCorrection, emptyValue);
                        if (!this.designTime)
                            this.checkSeparators();
                        // Create list of cells
                        this.report.cells.clear();
                        for (var colIndex = 0; colIndex < this.colCount; colIndex++) {
                            for (var rowIndex = 0; rowIndex < this.rowCount; rowIndex++) {
                                var cell = this.cells[colIndex][rowIndex];
                                if (cell.isNumeric && cell.value != null ? cell.value.sti.is(Number) : false)
                                    this.report.cells.setCell(colIndex, rowIndex, cell.value.sti.toNumber());
                                else
                                    this.report.cells.setCell(colIndex, rowIndex, 0);
                            }
                        }
                        // Post process cells
                        for (var colIndex = 0; colIndex < this.colCount; colIndex++) {
                            for (var rowIndex = 0; rowIndex < this.rowCount; rowIndex++) {
                                var cell = this.cells[colIndex][rowIndex];
                                if (cell.parentCell == cell) {
                                    // Image
                                    if (cell.field.sti.is(CrossTab.StiCrossSummary) && cell.field.summary == Core.StiSummaryType.Image) {
                                        cell.isImage = true;
                                    }
                                    var e = new CrossTab.StiProcessCellEventArgs();
                                    e.row = rowIndex;
                                    e.column = colIndex;
                                    e.cell = cell;
                                    var val = 0;
                                    if (cell.value != null ? cell.value.sti.is(Number) : false)
                                        val = cell.value.sti.toNumber();
                                    e.text = cell.text;
                                    e.value = val;
                                    report.cells.distX = colIndex;
                                    report.cells.distY = rowIndex;
                                    if (cell.field.sti.is(CrossTab.StiCrossTotal))
                                        cell.field = cell.field;
                                    if (cell.field != null)
                                        cell.field.invokeProcessCell(e);
                                    if (e.value != val) {
                                        this.report.cells.setCell(colIndex, rowIndex, e.value);
                                        cell.value = e.value;
                                        cell.text = cell.field.textFormat.format(e.value);
                                    }
                                    else {
                                        cell.text = e.text;
                                    }
                                    // Parse numeric values for excel export
                                    if (cell.isNumeric && cell.field != null) {
                                        if (cell.field.hideZeros) {
                                            if ((cell.value != null ? cell.value.sti.is(Number) : false) && cell.value.sti.toNumber() == 0)
                                                continue;
                                        }
                                        if (cell.value != null) {
                                            cell.field.excelDataValue = cell.value.toString();
                                        }
                                    }
                                }
                            }
                        }
                        if (this.isRowsEmpty && !this.isColsEmpty && this.isSummariesEmpty) // remove last unuseful row if only cols present in crosstab
                         {
                            this.heights.splice(this.heights.length - 1, 1);
                            for (var i = 0; i < this.cells.length; i++) {
                                this.cells[i].splice(this.cells[i].length - 1, 1);
                            }
                        }
                    };
                    StiCross.prototype.clear = function () {
                        var needGCCollect = false;
                        if ((this.cells != null) && (this.cells.length > 1) && (this.cells[0] != null)) {
                            var size = this.cells.length * this.cells[0].length;
                            if (size > 50000) {
                                needGCCollect = true;
                            }
                        }
                        this.cells = null;
                        return needGCCollect;
                    };
                    StiCross.prototype.getCorrectedColumnsHeaderHeight = function () {
                        return this.colsHeaderHeight + this.heightCorrection;
                    };
                    Object.defineProperty(StiCross.prototype, "isSummaryPresent", {
                        get: function () {
                            if (this.report.isDesigning)
                                return true;
                            return this.summaryCrossTitle != null && this.summaryCrossTitle.isEnabled;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "isRowTitlePresent", {
                        get: function () {
                            if (this.report.isDesigning)
                                return true;
                            for (var _i = 0, _a = this.rowFields.toCast(); _i < _a.length; _i++) {
                                var row = _a[_i];
                                if (!row.isEnabled)
                                    return false;
                            }
                            return true;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "isTopLinePresent", {
                        get: function () {
                            if (this.isColsEmpty)
                                return false;
                            if (this.leftCrossTitle == null && this.rightCrossTitle == null)
                                return false;
                            if (this.report.isDesigning)
                                return true;
                            if (this.leftCrossTitle.isEnabled && this.rightCrossTitle.isEnabled)
                                return true;
                            return false;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "isTopCrossTitleVisible", {
                        get: function () {
                            return !this.isRowsEmpty && this.isCrossTitleEnabled;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "isLeftCrossTitleVisible", {
                        get: function () {
                            return !this.isTopCrossTitleVisible && this.isCrossTitleEnabled;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "isCrossTitleEnabled", {
                        get: function () {
                            return (this.leftCrossTitle != null && this.leftCrossTitle.enabled &&
                                this.rightCrossTitle != null && this.rightCrossTitle.enabled) ||
                                (this.summaryCrossTitle != null && this.summaryCrossTitle.enabled);
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "isCrossTitlePrintOnAllPages", {
                        get: function () {
                            return (this.leftCrossTitle != null && this.leftCrossTitle.printOnAllPages &&
                                this.rightCrossTitle != null && this.rightCrossTitle.printOnAllPages) ||
                                (this.summaryCrossTitle != null && this.summaryCrossTitle.printOnAllPages);
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "isShowSummarySubHeaders", {
                        get: function () {
                            if (this.designTime)
                                return true;
                            for (var _i = 0, _a = this.sumHeaderFields.toCast(); _i < _a.length; _i++) {
                                var header = _a[_i];
                                if (header.enabled)
                                    return true;
                            }
                            return false;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "isSummarySubHeadersPresent", {
                        get: function () {
                            return this.sumFields.count > 1 &&
                                this.isShowSummarySubHeaders &&
                                this.sumHeaderFields.count > 1;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "isLeftTopLinePresent", {
                        get: function () {
                            if (!this.isTopLinePresent)
                                return false;
                            if (this.leftCrossTitle == null)
                                return false;
                            if (this.report.isDesigning)
                                return true;
                            return this.leftCrossTitle.isEnabled;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "isRightTopLinePresent", {
                        get: function () {
                            if (!this.isTopLinePresent)
                                return false;
                            if (this.rightCrossTitle == null)
                                return false;
                            if (this.report.isDesigning)
                                return true;
                            return this.rightCrossTitle.isEnabled;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "isRowsEmpty", {
                        get: function () {
                            return this.rowFields.count == 1 && this.rowFields.getByIndex(0).name == this.emptyField;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "isColsEmpty", {
                        get: function () {
                            return this.colFields.count == 1 && this.colFields.getByIndex(0).name == this.emptyField;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "isSummariesEmpty", {
                        get: function () {
                            return this.sumFields.count == 1 && this.sumFields.getByIndex(0).name == this.emptyField;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "rowFields", {
                        get: function () {
                            return this._rowFields;
                        },
                        set: function (value) {
                            if (value == null || value.count == 0) {
                                if (value == null)
                                    value = new StiComponentsCollection();
                                else
                                    value.clear();
                                var comp = new CrossTab.StiCrossRow();
                                comp.name = this.emptyField;
                                value.add(comp);
                            }
                            this._rowFields = value;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "colFields", {
                        get: function () {
                            return this._colFields;
                        },
                        set: function (value) {
                            if (value == null || value.count == 0) {
                                if (value == null)
                                    value = new StiComponentsCollection();
                                else
                                    value.clear();
                                var comp = new CrossTab.StiCrossColumn();
                                comp.name = this.emptyField;
                                value.add(comp);
                            }
                            this._colFields = value;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "sumFields", {
                        get: function () {
                            return this._sumFields;
                        },
                        set: function (value) {
                            if (value == null || value.count == 0) {
                                if (value == null)
                                    value = new StiComponentsCollection();
                                else
                                    value.clear();
                                var comp = new CrossTab.StiCrossSummary();
                                comp.name = this.emptyField;
                                value.add(comp);
                            }
                            this._sumFields = value;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    Object.defineProperty(StiCross.prototype, "sumHeaderFields", {
                        get: function () {
                            return this._sumHeaderFields;
                        },
                        set: function (value) {
                            if (value == null || value.count == 0) {
                                if (value == null)
                                    value = new StiComponentsCollection();
                                else
                                    value.clear();
                                var comp = new CrossTab.StiCrossSummaryHeader();
                                comp.name = this.emptyField;
                                value.add(comp);
                            }
                            this._sumHeaderFields = value;
                        },
                        enumerable: true,
                        configurable: true
                    });
                    StiCross.emptyField = "EMPTY_FIELD";
                    return StiCross;
                }(Core.StiGrid));
                Core.StiCross = StiCross;
            })(Core = CrossTab.Core || (CrossTab.Core = {}));
        })(CrossTab = Report.CrossTab || (Report.CrossTab = {}));
    })(Report = Stimulsoft.Report || (Stimulsoft.Report = {}));
})(Stimulsoft || (Stimulsoft = {}));