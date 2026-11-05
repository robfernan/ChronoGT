import Toybox.ActivityMonitor;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class ChronoGTView extends WatchUi.WatchFace {
    private var _isAwake as Boolean = true;
    private var _sleepShift as Number = 0;

    // Base Cluster Palette
    private const COLOR_BG = 0x000000;
    private const COLOR_TRACK = 0x333333;
    private const COLOR_AMBER = 0xFFAA00;
    private const COLOR_REDLINE = 0xFF2200;
    private const COLOR_CYAN = 0x00CCFF;
    private const COLOR_GREEN = 0x00FF66;
    private const COLOR_WHITE = 0xFFFFFF;
    private const COLOR_MUTED = 0x999999;

    // Cached Settings
    private var _cachedLayoutMode as Number = 0;
    private var _cachedTheme as Number = 0;
    private var _cachedGaugeMode as Number = 0;
    private var _cachedShowShiftLights as Boolean = true;
    private var _cachedRedlinePulse as Boolean = true;
    private var _cachedMetricSlotA as Number = 0;
    private var _cachedMetricSlotB as Number = 5;
    private var _cachedAccentColor as Number = COLOR_AMBER;

    // Shift Light Static Thresholds (Hoisted to prevent per-frame allocation)
    private const SHIFT_THRESHOLDS = [0.20f, 0.40f, 0.60f, 0.75f, 0.90f];
    private const SHIFT_COLORS = [COLOR_GREEN, COLOR_GREEN, COLOR_AMBER, COLOR_AMBER, COLOR_REDLINE];

    // Frame State (reused in onUpdate to eliminate parameter count limits and allocations)
    private var _clockTime as System.ClockTime?;
    private var _dateInfo as Gregorian.Info?;
    private var _actInfo as ActivityMonitor.Info?;
    private var _sysStats as System.Stats?;
    private var _hr as Number = 0;
    private var _gaugeRatio as Float = 0.0f;
    private var _isRedlinePulse as Boolean = false;

    function initialize() {
        WatchFace.initialize();
        reloadSettings();
    }

    public function reloadSettings() as Void {
        _cachedLayoutMode = 0;
        try {
            var lVal = Properties.getValue("LayoutMode");
            if (lVal != null && lVal instanceof Number) {
                _cachedLayoutMode = lVal;
            }
        } catch (e) {
            _cachedLayoutMode = 0;
        }

        _cachedTheme = 0;
        try {
            var val = Properties.getValue("AccentTheme");
            if (val != null && val instanceof Number) {
                _cachedTheme = val;
            }
        } catch (e) {
            _cachedTheme = 0;
        }

        if (_cachedTheme == 1) {
            _cachedAccentColor = COLOR_REDLINE;
        } else if (_cachedTheme == 2) {
            _cachedAccentColor = COLOR_CYAN;
        } else if (_cachedTheme == 3) {
            _cachedAccentColor = COLOR_GREEN;
        } else {
            _cachedAccentColor = COLOR_AMBER;
        }

        _cachedGaugeMode = 0;
        try {
            var val = Properties.getValue("GaugeMode");
            if (val != null && val instanceof Number) {
                _cachedGaugeMode = val;
            }
        } catch (e) {
            _cachedGaugeMode = 0;
        }

        _cachedShowShiftLights = true;
        try {
            var val = Properties.getValue("ShowShiftLights");
            if (val != null && val instanceof Boolean) {
                _cachedShowShiftLights = val;
            }
        } catch (e) {
            _cachedShowShiftLights = true;
        }

        _cachedRedlinePulse = true;
        try {
            var rpVal = Properties.getValue("RedlinePulse");
            if (rpVal != null && rpVal instanceof Boolean) {
                _cachedRedlinePulse = rpVal;
            }
        } catch (e) {
            _cachedRedlinePulse = true;
        }

        _cachedMetricSlotA = 0;
        try {
            var aVal = Properties.getValue("MetricSlotA");
            if (aVal != null && aVal instanceof Number) {
                _cachedMetricSlotA = aVal;
            }
        } catch (e) {
            _cachedMetricSlotA = 0;
        }

        _cachedMetricSlotB = 5;
        try {
            var bVal = Properties.getValue("MetricSlotB");
            if (bVal != null && bVal instanceof Number) {
                _cachedMetricSlotB = bVal;
            }
        } catch (e) {
            _cachedMetricSlotB = 5;
        }
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        reloadSettings();
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var cy = height / 2;
        var radius = (width < height ? width : height) / 2;

        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        // 1. Clear Background
        dc.setColor(COLOR_BG, COLOR_BG);
        dc.clear();

        var clockTime = System.getClockTime();
        _clockTime = clockTime;
        var now = Time.now();
        _dateInfo = Gregorian.info(now, Time.FORMAT_MEDIUM);

        // 2. Always-On Display (AOD) Burn-In Safe Mode when asleep
        if (!_isAwake) {
            _sleepShift = (clockTime.min % 3) - 1; // Shifts -1, 0, +1 px every minute
            var hour = clockTime.hour;
            if (!System.getDeviceSettings().is24Hour) {
                hour = hour % 12;
                if (hour == 0) {
                    hour = 12;
                }
            }
            var timeStr = Lang.format("$1$:$2$", [hour.format("%02d"), clockTime.min.format("%02d")]);
            var numFont = Graphics.FONT_NUMBER_MEDIUM;
            var numH = Graphics.getFontHeight(numFont);

            dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx + _sleepShift, cy - (numH / 2), numFont, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        // 3. Live Watch Telemetry (Steps, Goal, Heart Rate, System Stats)
        _actInfo = ActivityMonitor.getInfo();
        var actInfo = _actInfo;
        var steps = (actInfo != null && actInfo.steps != null) ? actInfo.steps : 0;
        var stepGoal = (actInfo != null && actInfo.stepGoal != null && actInfo.stepGoal > 0) ? actInfo.stepGoal : 8000;

        _hr = 0;
        if (ActivityMonitor has :getHeartRateHistory) {
            var hrIter = ActivityMonitor.getHeartRateHistory(1, true);
            if (hrIter != null) {
                var sample = hrIter.next();
                if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                    _hr = sample.heartRate;
                }
            }
        }

        _sysStats = System.getSystemStats();

        // 4. Compute Gauge Ratio based on selected GaugeMode (0=Seconds, 1=Steps, 2=Heart Rate)
        var gaugeMode = _cachedGaugeMode;
        var gaugeRatio = clockTime.sec.toFloat() / 60.0f;
        if (gaugeMode == 1) {
            gaugeRatio = steps.toFloat() / stepGoal.toFloat();
        } else if (gaugeMode == 2 && _hr > 45) {
            gaugeRatio = (_hr - 45).toFloat() / 145.0f;
        }
        if (gaugeRatio > 1.0f) {
            gaugeRatio = 1.0f;
        }
        if (gaugeRatio < 0.0f) {
            gaugeRatio = 0.0f;
        }
        _gaugeRatio = gaugeRatio;

        // Redline limiter pulse flag (:55 - :59 awake only, alternating flash)
        _isRedlinePulse = _cachedRedlinePulse && (clockTime.sec >= 55) && ((clockTime.sec % 2) == 1);

        // Render based on LayoutMode:
        // 0 = Classic JDM Analog
        // 1 = F1 / S2000 Progressive Ribbon
        // 2 = BX 19 Digit Retro Segmented
        if (_cachedLayoutMode == 1) {
            drawLayoutRibbon(dc, cx, cy, radius);
        } else if (_cachedLayoutMode == 2) {
            drawLayoutSegmented(dc, cx, cy, radius);
        } else {
            drawLayoutClassic(dc, cx, cy, radius);
        }
    }

    // ==========================================
    // LAYOUT 0: CLASSIC JDM ANALOG (RX-7 / DEFI)
    // ==========================================
    private function drawLayoutClassic(dc as Dc, cx as Number, cy as Number, radius as Number) as Void {
        var clockTime = _clockTime;
        var dateInfo = _dateInfo;
        if (clockTime == null || dateInfo == null) {
            return;
        }
        var accentColor = _cachedAccentColor;

        // 1. Gauge Scale
        drawClassicGaugeScale(dc, cx, cy, radius, _gaugeRatio, accentColor);

        // 2. Sequential Shift Lights
        if (_cachedShowShiftLights) {
            drawShiftLights(dc, cx, cy - (radius * 58) / 100, _gaugeRatio);
        }

        // 3. Date Readout
        var dateStr = Lang.format("$1$ $2$", [dateInfo.day_of_week.toUpper(), dateInfo.day.format("%02d")]);
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - (radius * 46) / 100, Graphics.FONT_TINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);

        // 4. Center Digital Time & Seconds
        var hour = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }
        var timeStr = Lang.format("$1$:$2$", [hour.format("%02d"), clockTime.min.format("%02d")]);
        var numFont = Graphics.FONT_NUMBER_MEDIUM;
        var numH = Graphics.getFontHeight(numFont);
        var timeY = cy - (numH / 2) - (radius * 6) / 100;

        dc.setColor(COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, timeY, numFont, timeStr, Graphics.TEXT_JUSTIFY_CENTER);

        var secStr = ":" + clockTime.sec.format("%02d");
        dc.setColor(_isRedlinePulse ? COLOR_REDLINE : accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + (radius * 18) / 100, Graphics.FONT_SMALL, secStr, Graphics.TEXT_JUSTIFY_CENTER);

        // 5. Configurable Metric Slots A & B
        var slotAY = cy + (radius * 43) / 100;
        var slotAX = cx - (radius * 40) / 100;
        var slotBX = cx + (radius * 40) / 100;

        var strA = ChronoGTMetrics.getMetricString(_cachedMetricSlotA, _actInfo, _sysStats, _hr);
        var strB = ChronoGTMetrics.getMetricString(_cachedMetricSlotB, _actInfo, _sysStats, _hr);

        if (strA.length() > 0) {
            dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(slotAX, slotAY, Graphics.FONT_XTINY, strA, Graphics.TEXT_JUSTIFY_CENTER);
        }

        if (strB.length() > 0) {
            var colorB = (_cachedMetricSlotB == 5 && _hr > 0) ? COLOR_REDLINE : COLOR_MUTED;
            dc.setColor(colorB, Graphics.COLOR_TRANSPARENT);
            dc.drawText(slotBX, slotAY, Graphics.FONT_XTINY, strB, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Center Step Counter & Goal Bar
        var actInfo = _actInfo;
        var steps = (actInfo != null && actInfo.steps != null) ? actInfo.steps : 0;
        var stepGoal = (actInfo != null && actInfo.stepGoal != null && actInfo.stepGoal > 0) ? actInfo.stepGoal : 8000;
        dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + (radius * 60) / 100, Graphics.FONT_XTINY, steps.format("%d") + " STEPS", Graphics.TEXT_JUSTIFY_CENTER);

        var barW = (radius * 54) / 100;
        var barH = 4;
        var barX = cx - (barW / 2);
        var barY = cy + (radius * 75) / 100;
        var stepRatio = steps.toFloat() / stepGoal.toFloat();
        if (stepRatio > 1.0f) {
            stepRatio = 1.0f;
        }
        dc.setColor(COLOR_TRACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, barY, barW, barH);
        if (stepRatio > 0.0f) {
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(barX, barY, (barW * stepRatio).toNumber(), barH);
        }

        // 6. Sweeping Perimeter Gauge Needle
        drawClassicNeedle(dc, cx, cy, radius, _gaugeRatio);
    }

    private function drawClassicGaugeScale(dc as Dc, cx as Number, cy as Number, radius as Number, ratio as Float, accentColor as Number) as Void {
        var outerR = radius - 6;
        var majorInnerR = radius - 18;
        var minorInnerR = radius - 12;

        dc.setColor(COLOR_TRACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawArc(cx, cy, outerR, Graphics.ARC_CLOCKWISE, 210, 330);

        dc.setColor(_isRedlinePulse ? COLOR_WHITE : COLOR_REDLINE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawArc(cx, cy, outerR, Graphics.ARC_CLOCKWISE, 30, 330);

        for (var i = 0; i <= 24; i++) {
            var frac = i.toFloat() / 24.0f;
            var angleDeg = 210.0f - (frac * 240.0f);
            var rad = Math.toRadians(angleDeg);
            var cosA = Math.cos(rad);
            var sinA = Math.sin(rad);

            var isMajor = (i % 2 == 0);
            var tickInner = isMajor ? majorInnerR : minorInnerR;

            if (i >= 18) {
                dc.setColor(_isRedlinePulse ? COLOR_WHITE : COLOR_REDLINE, Graphics.COLOR_TRANSPARENT);
            } else if (frac <= ratio) {
                dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
            }

            dc.setPenWidth(isMajor ? 3 : 1);
            var x1 = cx + (outerR * cosA).toNumber();
            var y1 = cy - (outerR * sinA).toNumber();
            var x2 = cx + (tickInner * cosA).toNumber();
            var y2 = cy - (tickInner * sinA).toNumber();
            dc.drawLine(x1, y1, x2, y2);
        }
        dc.setPenWidth(1);
    }

    private function drawClassicNeedle(dc as Dc, cx as Number, cy as Number, radius as Number, ratio as Float) as Void {
        var angleDeg = 210.0f - (ratio * 240.0f);
        var rad = Math.toRadians(angleDeg);
        var cosA = Math.cos(rad);
        var sinA = Math.sin(rad);

        var outerTip = radius - 10;
        var innerTail = radius - 32;

        var x1 = cx + (innerTail * cosA).toNumber();
        var y1 = cy - (innerTail * sinA).toNumber();
        var x2 = cx + (outerTip * cosA).toNumber();
        var y2 = cy - (outerTip * sinA).toNumber();

        dc.setColor(_isRedlinePulse ? COLOR_WHITE : COLOR_REDLINE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawLine(x1, y1, x2, y2);
        dc.setPenWidth(1);
    }

    // ==========================================
    // LAYOUT 1: TRUE HONDA S2000 AP1 CLUSTER
    // ==========================================
    // Distinct Features:
    // 1. Signature "stepped hockey-stick" progressive tach curve across the top
    // 2. Twin vertical flank bar gauges: Left = Battery % (AP1 Temp), Right = Steps / Goal (AP1 Fuel)
    // 3. Huge digital speedo time (HH:MM) centered directly below horizontal tach sweep
    // 4. Sequential F1/VTEC shift lights nestled above speedo
    private function drawLayoutRibbon(dc as Dc, cx as Number, cy as Number, radius as Number) as Void {
        var clockTime = _clockTime;
        var dateInfo = _dateInfo;
        if (clockTime == null || dateInfo == null) {
            return;
        }
        var accentColor = _cachedAccentColor;

        // 1. AP1 Stepped Progressive Tachometer Arc (18 polygon segments)
        // Starts low-left, steps up aggressively, runs flat horizontal across top, terminates in redline blocks on right
        var segments = 18;
        var rOuterBase = radius - 8;
        var rInnerBase = radius - 24;

        for (var i = 0; i < segments; i++) {
            var fracStart = i.toFloat() / segments.toFloat();
            var fracEnd = (i + 1).toFloat() / segments.toFloat();

            // Angles sweep from 195° (low left) to -15° (right redline)
            var a1 = 195.0f - (fracStart * 210.0f);
            var a2 = 195.0f - (fracEnd * 210.0f) + 1.2f;

            // AP1 Step Geometry: segments 0-5 climb up, segments 6-13 run flat, 14-17 drop into 9k redline
            var rOut1 = rOuterBase;
            var rOut2 = rOuterBase;
            var rIn1 = rInnerBase;
            var rIn2 = rInnerBase;

            if (i < 5) {
                // Rising ramp (left flank)
                var lift1 = (5 - i) * 2;
                var lift2 = (4 - i) * 2;
                rOut1 = rOuterBase - lift1;
                rOut2 = rOuterBase - lift2;
            }

            var rad1 = Math.toRadians(a1);
            var rad2 = Math.toRadians(a2);

            var poly = [
                [cx + (rOut1 * Math.cos(rad1)).toNumber(), cy - (rOut1 * Math.sin(rad1)).toNumber()],
                [cx + (rOut2 * Math.cos(rad2)).toNumber(), cy - (rOut2 * Math.sin(rad2)).toNumber()],
                [cx + (rIn2 * Math.cos(rad2)).toNumber(), cy - (rIn2 * Math.sin(rad2)).toNumber()],
                [cx + (rIn1 * Math.cos(rad1)).toNumber(), cy - (rIn1 * Math.sin(rad1)).toNumber()]
            ];

            var isRedZone = (i >= 14); // 9k Redline
            if (fracStart <= _gaugeRatio) {
                if (isRedZone) {
                    dc.setColor(_isRedlinePulse ? COLOR_WHITE : COLOR_REDLINE, Graphics.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
                }
            } else {
                dc.setColor(COLOR_TRACK, Graphics.COLOR_TRANSPARENT);
            }
            dc.fillPolygon(poly);
        }

        // 2. Sequential VTEC Shift Lights nestled under the top horizontal sweep
        if (_cachedShowShiftLights) {
            drawShiftLights(dc, cx, cy - (radius * 44) / 100, _gaugeRatio);
        }

        // 3. S2000 AP1 Digital Speedo (HH:MM)
        var hour = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }
        var timeStr = Lang.format("$1$:$2$", [hour.format("%02d"), clockTime.min.format("%02d")]);
        var numFont = Graphics.FONT_NUMBER_HOT;
        var numH = Graphics.getFontHeight(numFont);
        var timeY = cy - (numH / 2) - (radius * 8) / 100;

        dc.setColor(COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, timeY, numFont, timeStr, Graphics.TEXT_JUSTIFY_CENTER);

        // 4. Iconic AP1 Flanking Vertical Auxiliary Bars
        // Left Flank Bar = Battery % (AP1 Engine Temp)
        var sysStats = _sysStats;
        var batVal = (sysStats != null && sysStats.battery != null) ? sysStats.battery.toNumber() : 100;
        var batRatio = batVal.toFloat() / 100.0f;
        drawAP1FlankBar(dc, cx - (radius * 78) / 100, cy + (radius * 4) / 100, (radius * 32) / 100, batRatio, (batVal <= 20) ? COLOR_REDLINE : accentColor);

        // Right Flank Bar = Steps / Goal (AP1 Fuel Level)
        var actInfo = _actInfo;
        var steps = (actInfo != null && actInfo.steps != null) ? actInfo.steps : 0;
        var stepGoal = (actInfo != null && actInfo.stepGoal != null && actInfo.stepGoal > 0) ? actInfo.stepGoal : 8000;
        var stepRatio = steps.toFloat() / stepGoal.toFloat();
        if (stepRatio > 1.0f) {
            stepRatio = 1.0f;
        }
        drawAP1FlankBar(dc, cx + (radius * 72) / 100, cy + (radius * 4) / 100, (radius * 32) / 100, stepRatio, accentColor);

        // 5. Date Readout (clean spacing below large time digits)
        var dateStr = Lang.format("$1$ $2$", [dateInfo.day_of_week.toUpper(), dateInfo.day.format("%02d")]);
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + (radius * 16) / 100, Graphics.FONT_TINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);

        // 6. Telemetry Row: Slot A, Live Seconds, Slot B (spread wide to avoid collision)
        var strA = ChronoGTMetrics.getMetricString(_cachedMetricSlotA, _actInfo, _sysStats, _hr);
        var strB = ChronoGTMetrics.getMetricString(_cachedMetricSlotB, _actInfo, _sysStats, _hr);
        var rowY = cy + (radius * 40) / 100;

        if (strA.length() > 0) {
            dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx - (radius * 48) / 100, rowY + 2, Graphics.FONT_XTINY, strA, Graphics.TEXT_JUSTIFY_CENTER);
        }

        var secStr = ":" + clockTime.sec.format("%02d");
        dc.setColor(_isRedlinePulse ? COLOR_REDLINE : accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, rowY, Graphics.FONT_SMALL, secStr, Graphics.TEXT_JUSTIFY_CENTER);

        if (strB.length() > 0) {
            var colorB = (_cachedMetricSlotB == 5 && _hr > 0) ? COLOR_REDLINE : COLOR_MUTED;
            dc.setColor(colorB, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx + (radius * 48) / 100, rowY + 2, Graphics.FONT_XTINY, strB, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Bottom Steps Total
        dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + (radius * 65) / 100, Graphics.FONT_XTINY, steps.format("%d") + " STEPS", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Helper: 5-segment vertical ladder bar for AP1 flank gauges
    private function drawAP1FlankBar(dc as Dc, x as Number, yTop as Number, height as Number, ratio as Float, color as Number) as Void {
        var segments = 5;
        var barW = 5;
        var segH = (height / segments) - 2;

        for (var i = 0; i < segments; i++) {
            var segY = yTop + height - ((i + 1) * (segH + 2));
            var segFrac = (i + 1).toFloat() / segments.toFloat();

            if (segFrac <= ratio + 0.15f) {
                dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(COLOR_TRACK, Graphics.COLOR_TRANSPARENT);
            }
            dc.fillRectangle(x, segY, barW, segH);
        }
    }

    // ==========================================
    // LAYOUT 2: TRUE CITROEN BX 19 DIGIT (1985 VFD)
    // ==========================================
    // Distinct Features:
    // 1. Dual Nested Neon Arcs: Outer tachometer + Inner speedo graph
    // 2. 1980s VFD Bordered Readout Box [ 12:45 :SS ] properly sized with zero overlaps
    // 3. Satellite Diagnostic Readout Tiles [ 50% ] & [ 80 BPM ]
    // 4. High-contrast French synthwave dashboard geometry
    private function drawLayoutSegmented(dc as Dc, cx as Number, cy as Number, radius as Number) as Void {
        var clockTime = _clockTime;
        var dateInfo = _dateInfo;
        if (clockTime == null || dateInfo == null) {
            return;
        }
        var accentColor = _cachedAccentColor;

        // 1. Dual Nested Neon Geometric Arcs
        var segments = 20;
        var rOuter = radius - 8;
        var rInner = radius - 20;

        for (var i = 0; i < segments; i++) {
            var fracStart = i.toFloat() / segments.toFloat();
            var fracEnd = (i + 1).toFloat() / segments.toFloat();

            var a1 = 220.0f - (fracStart * 260.0f);
            var a2 = 220.0f - (fracEnd * 260.0f) + 2.5f;

            var rad1 = Math.toRadians(a1);
            var rad2 = Math.toRadians(a2);

            var poly = [
                [cx + (rOuter * Math.cos(rad1)).toNumber(), cy - (rOuter * Math.sin(rad1)).toNumber()],
                [cx + (rOuter * Math.cos(rad2)).toNumber(), cy - (rOuter * Math.sin(rad2)).toNumber()],
                [cx + (rInner * Math.cos(rad2)).toNumber(), cy - (rInner * Math.sin(rad2)).toNumber()],
                [cx + (rInner * Math.cos(rad1)).toNumber(), cy - (rInner * Math.sin(rad1)).toNumber()]
            ];

            var isRedZone = (i >= 16);
            if (fracStart <= _gaugeRatio) {
                if (isRedZone) {
                    dc.setColor(_isRedlinePulse ? COLOR_WHITE : COLOR_REDLINE, Graphics.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
                }
            } else {
                dc.setColor(COLOR_TRACK, Graphics.COLOR_TRANSPARENT);
            }
            dc.fillPolygon(poly);
        }

        // Inner nested continuous line arc (kept within outer rim, stops before box)
        dc.setColor(COLOR_TRACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawArc(cx, cy, radius - 26, Graphics.ARC_CLOCKWISE, 220, 320);
        if (_gaugeRatio > 0.05f) {
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
            var endDeg = (220.0f - (_gaugeRatio * 260.0f)).toNumber();
            if (endDeg < 0) {
                endDeg += 360;
            }
            dc.drawArc(cx, cy, radius - 26, Graphics.ARC_CLOCKWISE, 220, endDeg);
        }
        dc.setPenWidth(1);

        // 2. Sequential Shift Lights
        if (_cachedShowShiftLights) {
            drawShiftLights(dc, cx, cy - (radius * 50) / 100, _gaugeRatio);
        }

        // 3. Central 1980s VFD Bordered Readout Box
        // Use FONT_LARGE or FONT_MEDIUM based on resolution so it never bursts the box
        var numFont = (radius >= 180) ? Graphics.FONT_LARGE : Graphics.FONT_MEDIUM;
        var numH = Graphics.getFontHeight(numFont);

        var boxW = (radius * 136) / 100;
        var boxH = numH + 12;
        var boxX = cx - (boxW / 2);
        var boxY = cy - (boxH / 2) - (radius * 8) / 100;

        // Base Box Outline (dark track)
        dc.setColor(COLOR_TRACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRectangle(boxX, boxY, boxW, boxH);

        // Glowing Corner Brackets (accent color)
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        var cornerLen = 8;
        // Top-left
        dc.drawLine(boxX, boxY, boxX + cornerLen, boxY);
        dc.drawLine(boxX, boxY, boxX, boxY + cornerLen);
        // Top-right
        dc.drawLine(boxX + boxW, boxY, boxX + boxW - cornerLen, boxY);
        dc.drawLine(boxX + boxW, boxY, boxX + boxW, boxY + cornerLen);
        // Bottom-left
        dc.drawLine(boxX, boxY + boxH, boxX + cornerLen, boxY + boxH);
        dc.drawLine(boxX, boxY + boxH, boxX, boxY + boxH - cornerLen);
        // Bottom-right
        dc.drawLine(boxX + boxW, boxY + boxH, boxX + boxW - cornerLen, boxY + boxH);
        dc.drawLine(boxX + boxW, boxY + boxH, boxX + boxW, boxY + boxH - cornerLen);

        // Digital Time (cleanly centered inside the box)
        var hour = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }
        var timeStr = Lang.format("$1$:$2$", [hour.format("%02d"), clockTime.min.format("%02d")]);

        dc.setColor(COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - (radius * 16) / 100, boxY + (boxH / 2) - (numH / 2), numFont, timeStr, Graphics.TEXT_JUSTIFY_CENTER);

        // Live Seconds alongside minutes
        var secStr = ":" + clockTime.sec.format("%02d");
        var secFont = (radius >= 180) ? Graphics.FONT_SMALL : Graphics.FONT_TINY;
        var secH = Graphics.getFontHeight(secFont);
        dc.setColor(_isRedlinePulse ? COLOR_REDLINE : accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + (radius * 36) / 100, boxY + (boxH / 2) - (secH / 2), secFont, secStr, Graphics.TEXT_JUSTIFY_CENTER);

        // 4. Satellite Diagnostic Tiles (BX Digit Trip Computer Readouts)
        var tileY = cy + (radius * 28) / 100;
        var strA = ChronoGTMetrics.getMetricString(_cachedMetricSlotA, _actInfo, _sysStats, _hr);
        var strB = ChronoGTMetrics.getMetricString(_cachedMetricSlotB, _actInfo, _sysStats, _hr);

        if (strA.length() > 0) {
            dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx - (radius * 40) / 100, tileY, Graphics.FONT_XTINY, "[" + strA + "]", Graphics.TEXT_JUSTIFY_CENTER);
        }

        if (strB.length() > 0) {
            var colorB = (_cachedMetricSlotB == 5 && _hr > 0) ? COLOR_REDLINE : COLOR_MUTED;
            dc.setColor(colorB, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx + (radius * 40) / 100, tileY, Graphics.FONT_XTINY, "[" + strB + "]", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Date Readout
        var dateStr = Lang.format("$1$ $2$", [dateInfo.day_of_week.toUpper(), dateInfo.day.format("%02d")]);
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + (radius * 48) / 100, Graphics.FONT_TINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);

        // Bottom Steps Telemetry
        var actInfo = _actInfo;
        var steps = (actInfo != null && actInfo.steps != null) ? actInfo.steps : 0;
        dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + (radius * 68) / 100, Graphics.FONT_XTINY, steps.format("%d") + " STEPS", Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawShiftLights(dc as Dc, cx as Number, y as Number, ratio as Float) as Void {
        var spacing = 14;
        var startX = cx - (spacing * 2);

        for (var i = 0; i < 5; i++) {
            var dotX = startX + (i * spacing);
            if (_isRedlinePulse) {
                // Flash all shift lights during pulse
                dc.setColor(COLOR_REDLINE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, y, 3);
            } else if (ratio >= SHIFT_THRESHOLDS[i]) {
                dc.setColor(SHIFT_COLORS[i], Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, y, 3);
            } else {
                dc.setColor(COLOR_TRACK, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, y, 2);
            }
        }
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        _isAwake = true;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        _isAwake = false;
        WatchUi.requestUpdate();
    }
}
