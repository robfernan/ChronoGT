import Toybox.Application.Properties;
import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class ChronoGTSettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "ChronoGT Settings"});

        var currentLayout = 0;
        try {
            var val = Properties.getValue("LayoutMode");
            if (val != null && val instanceof Number) {
                currentLayout = val;
            }
        } catch (e) {
            currentLayout = 0;
        }

        var currentTheme = 0;
        try {
            var val = Properties.getValue("AccentTheme");
            if (val != null && val instanceof Number) {
                currentTheme = val;
            }
        } catch (e) {
            currentTheme = 0;
        }

        var currentGauge = 0;
        try {
            var gVal = Properties.getValue("GaugeMode");
            if (gVal != null && gVal instanceof Number) {
                currentGauge = gVal;
            }
        } catch (e) {
            currentGauge = 0;
        }

        var showLights = true;
        try {
            var lVal = Properties.getValue("ShowShiftLights");
            if (lVal != null && lVal instanceof Boolean) {
                showLights = lVal;
            }
        } catch (e) {
            showLights = true;
        }

        var redlinePulse = true;
        try {
            var rpVal = Properties.getValue("RedlinePulse");
            if (rpVal != null && rpVal instanceof Boolean) {
                redlinePulse = rpVal;
            }
        } catch (e) {
            redlinePulse = true;
        }

        var slotA = 0;
        try {
            var aVal = Properties.getValue("MetricSlotA");
            if (aVal != null && aVal instanceof Number) {
                slotA = aVal;
            }
        } catch (e) {
            slotA = 0;
        }

        var slotB = 5;
        try {
            var bVal = Properties.getValue("MetricSlotB");
            if (bVal != null && bVal instanceof Number) {
                slotB = bVal;
            }
        } catch (e) {
            slotB = 5;
        }

        addItem(new WatchUi.MenuItem("Layout Style", getLayoutName(currentLayout), "menu_layout", null));
        addItem(new WatchUi.MenuItem("Accent Theme", getThemeName(currentTheme), "menu_theme", null));
        addItem(new WatchUi.MenuItem("Gauge Mode", getGaugeName(currentGauge), "menu_gauge", null));
        addItem(new WatchUi.MenuItem("Shift Lights", showLights ? "Enabled" : "Disabled", "menu_lights", null));
        addItem(new WatchUi.MenuItem("Redline Pulse", redlinePulse ? "Enabled (:55-:59)" : "Disabled", "menu_pulse", null));
        addItem(new WatchUi.MenuItem("Slot Left", getSlotName(slotA), "menu_slota", null));
        addItem(new WatchUi.MenuItem("Slot Right", getSlotName(slotB), "menu_slotb", null));
    }

    public static function getLayoutName(layout as Number) as String {
        switch (layout) {
            case 1:
                return "S2000 Ribbon";
            case 2:
                return "BX 19 Digit";
            case 0:
            default:
                return "Classic JDM";
        }
    }

    public static function getThemeName(theme as Number) as String {
        switch (theme) {
            case 1:
                return "Redline Red";
            case 2:
                return "Track Cyan";
            case 3:
                return "Tach Green";
            case 0:
            default:
                return "JDM Amber";
        }
    }

    public static function getGaugeName(gauge as Number) as String {
        switch (gauge) {
            case 1:
                return "Daily Steps";
            case 2:
                return "Heart Rate";
            case 0:
            default:
                return "Seconds (Tach)";
        }
    }

    public static function getSlotName(slot as Number) as String {
        return ChronoGTMetrics.getMetricLabel(slot);
    }
}

class ChronoGTSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if (id.equals("menu_layout")) {
            var current = 0;
            try {
                var val = Properties.getValue("LayoutMode");
                if (val != null && val instanceof Number) {
                    current = val;
                }
            } catch (e) {
                current = 0;
            }
            // Cycle 0 -> 1 -> 2 -> 0
            var nextLayout = (current + 1) % 3;
            try {
                Properties.setValue("LayoutMode", nextLayout);
            } catch (e) {
            }

            item.setSubLabel(ChronoGTSettingsMenu.getLayoutName(nextLayout));
            WatchUi.requestUpdate();

        } else if (id.equals("menu_theme")) {
            var current = 0;
            try {
                var val = Properties.getValue("AccentTheme");
                if (val != null && val instanceof Number) {
                    current = val;
                }
            } catch (e) {
                current = 0;
            }
            // Cycle 0 -> 1 -> 2 -> 3 -> 0
            var nextTheme = (current + 1) % 4;
            try {
                Properties.setValue("AccentTheme", nextTheme);
            } catch (e) {
            }

            item.setSubLabel(ChronoGTSettingsMenu.getThemeName(nextTheme));
            WatchUi.requestUpdate();

        } else if (id.equals("menu_gauge")) {
            var currentG = 0;
            try {
                var val = Properties.getValue("GaugeMode");
                if (val != null && val instanceof Number) {
                    currentG = val;
                }
            } catch (e) {
                currentG = 0;
            }
            // Cycle 0 -> 1 -> 2 -> 0
            var nextGauge = (currentG + 1) % 3;
            try {
                Properties.setValue("GaugeMode", nextGauge);
            } catch (e) {
            }

            item.setSubLabel(ChronoGTSettingsMenu.getGaugeName(nextGauge));
            WatchUi.requestUpdate();

        } else if (id.equals("menu_lights")) {
            var currentL = true;
            try {
                var val = Properties.getValue("ShowShiftLights");
                if (val != null && val instanceof Boolean) {
                    currentL = val;
                }
            } catch (e) {
                currentL = true;
            }
            var nextLights = !currentL;
            try {
                Properties.setValue("ShowShiftLights", nextLights);
            } catch (e) {
            }

            item.setSubLabel(nextLights ? "Enabled" : "Disabled");
            WatchUi.requestUpdate();

        } else if (id.equals("menu_pulse")) {
            var currentP = true;
            try {
                var val = Properties.getValue("RedlinePulse");
                if (val != null && val instanceof Boolean) {
                    currentP = val;
                }
            } catch (e) {
                currentP = true;
            }
            var nextPulse = !currentP;
            try {
                Properties.setValue("RedlinePulse", nextPulse);
            } catch (e) {
            }

            item.setSubLabel(nextPulse ? "Enabled (:55-:59)" : "Disabled");
            WatchUi.requestUpdate();

        } else if (id.equals("menu_slota")) {
            var currentA = 0;
            try {
                var val = Properties.getValue("MetricSlotA");
                if (val != null && val instanceof Number) {
                    currentA = val;
                }
            } catch (e) {
                currentA = 0;
            }
            // Cycle 0..6
            var nextA = (currentA + 1) % 7;
            try {
                Properties.setValue("MetricSlotA", nextA);
            } catch (e) {
            }

            item.setSubLabel(ChronoGTSettingsMenu.getSlotName(nextA));
            WatchUi.requestUpdate();

        } else if (id.equals("menu_slotb")) {
            var currentB = 5;
            try {
                var val = Properties.getValue("MetricSlotB");
                if (val != null && val instanceof Number) {
                    currentB = val;
                }
            } catch (e) {
                currentB = 5;
            }
            // Cycle 0..6
            var nextB = (currentB + 1) % 7;
            try {
                Properties.setValue("MetricSlotB", nextB);
            } catch (e) {
            }

            item.setSubLabel(ChronoGTSettingsMenu.getSlotName(nextB));
            WatchUi.requestUpdate();
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
