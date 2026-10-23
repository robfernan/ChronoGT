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

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    private function getAccentColor() as Number {
        var theme = 0;
        try {
            var val = Properties.getValue("AccentTheme");
            if (val != null && val instanceof Number) {
                theme = val;
            }
        } catch (e) {
            theme = 0;
        }
        if (theme == 1) {
            return COLOR_REDLINE;
        } else if (theme == 2) {
            return COLOR_CYAN;
        } else if (theme == 3) {
            return COLOR_GREEN;
        }
        return COLOR_AMBER;
    }

    private function getGaugeMode() as Number {
        try {
            var val = Properties.getValue("GaugeMode");
            if (val != null && val instanceof Number) {
                return val;
            }
        } catch (e) {
        }
        return 0;
    }

    private function getShowShiftLights() as Boolean {
        try {
            var val = Properties.getValue("ShowShiftLights");
            if (val != null && val instanceof Boolean) {
                return val;
            }
        } catch (e) {
        }
        return true;
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var cy = height / 2;
        var radius = (width < height ? width : height) / 2;

        // Enable anti-aliasing on high-res AMOLED/MIP screens if supported
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        // 1. Clear Background
        dc.setColor(COLOR_BG, COLOR_BG);
        dc.clear();

        var clockTime = System.getClockTime();
        var now = Time.now();
        var dateInfo = Gregorian.info(now, Time.FORMAT_MEDIUM);
        var accentColor = getAccentColor();

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

        // 3. Live Watch Telemetry (Steps, Goal, Heart Rate, Battery)
        var actInfo = ActivityMonitor.getInfo();
        var steps = (actInfo != null && actInfo.steps != null) ? actInfo.steps : 0;
        var stepGoal = (actInfo != null && actInfo.stepGoal != null && actInfo.stepGoal > 0) ? actInfo.stepGoal : 8000;

        var hr = 0;
        if (ActivityMonitor has :getHeartRateHistory) {
            var hrIter = ActivityMonitor.getHeartRateHistory(1, true);
            if (hrIter != null) {
                var sample = hrIter.next();
                if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                    hr = sample.heartRate;
                }
            }
        }

        var sysStats = System.getSystemStats();
        var battery = (sysStats != null) ? sysStats.battery.toNumber() : 100;

        // 4. Compute Gauge Ratio based on selected GaugeMode (0=Seconds, 1=Steps, 2=Heart Rate)
        var gaugeMode = getGaugeMode();
        var gaugeRatio = clockTime.sec.toFloat() / 60.0f;
        if (gaugeMode == 1) {
            gaugeRatio = steps.toFloat() / stepGoal.toFloat();
        } else if (gaugeMode == 2 && hr > 45) {
            gaugeRatio = (hr - 45).toFloat() / 145.0f;
        }
        if (gaugeRatio > 1.0f) {
            gaugeRatio = 1.0f;
        }
        if (gaugeRatio < 0.0f) {
            gaugeRatio = 0.0f;
        }

        // 5. Draw 240-Degree Racing Gauge Arc & Ticks
        drawGaugeScale(dc, cx, cy, radius, gaugeRatio, accentColor);

        // 6. Optional Sequential F1/JDM Shift-Light LEDs above Date
        if (getShowShiftLights()) {
            drawShiftLights(dc, cx, cy - (radius * 58) / 100, gaugeRatio);
        }

        // 7. Top Date Readout (e.g. "FRI 23")
        var dateStr = Lang.format("$1$ $2$", [dateInfo.day_of_week.toUpper(), dateInfo.day.format("%02d")]);
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - (radius * 46) / 100, Graphics.FONT_TINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);

        // 8. Center Digital Time + Live Seconds (e.g. "09:20" + ":42")
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
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + (radius * 18) / 100, Graphics.FONT_SMALL, secStr, Graphics.TEXT_JUSTIFY_CENTER);

        // 9. Clean Bottom Watch Metrics: Battery % | Heart Rate | Steps + Step Goal Progress Bar
        var bottomY = cy + (radius * 43) / 100;
        var batColor = (battery <= 20) ? COLOR_REDLINE : COLOR_MUTED;
        dc.setColor(batColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - (radius * 38) / 100, bottomY, Graphics.FONT_XTINY, battery.format("%d") + "%", Graphics.TEXT_JUSTIFY_CENTER);

        var hrStr = (hr > 0) ? (hr.format("%d") + " BPM") : "-- BPM";
        dc.setColor(COLOR_REDLINE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + (radius * 38) / 100, bottomY, Graphics.FONT_XTINY, hrStr, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + (radius * 60) / 100, Graphics.FONT_XTINY, steps.format("%d") + " STEPS", Graphics.TEXT_JUSTIFY_CENTER);

        // Subtle Step Goal Progress Bar underneath STEPS
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

        // 10. Sweeping Perimeter Gauge Needle
        drawGaugeNeedle(dc, cx, cy, radius, gaugeRatio);
    }

    // 5-dot sequential shift-light array (Green -> Green -> Amber -> Amber -> Redline)
    private function drawShiftLights(dc as Dc, cx as Number, y as Number, ratio as Float) as Void {
        var spacing = 14;
        var startX = cx - (spacing * 2);
        var thresholds = [0.20f, 0.40f, 0.60f, 0.75f, 0.90f];
        var colors = [COLOR_GREEN, COLOR_GREEN, COLOR_AMBER, COLOR_AMBER, COLOR_REDLINE];

        for (var i = 0; i < 5; i++) {
            var dotX = startX + (i * spacing);
            if (ratio >= thresholds[i]) {
                dc.setColor(colors[i], Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, y, 3);
            } else {
                dc.setColor(COLOR_TRACK, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, y, 2);
            }
        }
    }

    // 240-degree gauge scale from 210 deg (bottom-left) to -30 deg (bottom-right)
    private function drawGaugeScale(dc as Dc, cx as Number, cy as Number, radius as Number, ratio as Float, accentColor as Number) as Void {
        var outerR = radius - 6;
        var majorInnerR = radius - 18;
        var minorInnerR = radius - 12;

        dc.setColor(COLOR_TRACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawArc(cx, cy, outerR, Graphics.ARC_CLOCKWISE, 210, 330);

        dc.setColor(COLOR_REDLINE, Graphics.COLOR_TRANSPARENT);
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
                dc.setColor(COLOR_REDLINE, Graphics.COLOR_TRANSPARENT);
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

    private function drawGaugeNeedle(dc as Dc, cx as Number, cy as Number, radius as Number, ratio as Float) as Void {
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

        dc.setColor(COLOR_REDLINE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawLine(x1, y1, x2, y2);
        dc.setPenWidth(1);
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
