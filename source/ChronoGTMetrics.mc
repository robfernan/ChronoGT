import Toybox.ActivityMonitor;
import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;

class ChronoGTMetrics {

    // Metric Slot Enum:
    // 0 = Battery %
    // 1 = Steps
    // 2 = Remaining Steps to Goal
    // 3 = Calories (kCal)
    // 4 = Distance (mi/km)
    // 5 = Heart Rate (BPM)
    // 6 = None

    public static function getMetricLabel(type as Number) as String {
        switch (type) {
            case 0:
                return "Battery";
            case 1:
                return "Steps";
            case 2:
                return "Remaining";
            case 3:
                return "Calories";
            case 4:
                return "Distance";
            case 5:
                return "Heart Rate";
            case 6:
                return "None";
            default:
                return "None";
        }
    }

    public static function getMetricString(type as Number, actInfo as ActivityMonitor.Info?, sysStats as System.Stats?, hr as Number) as String {
        switch (type) {
            case 0: // Battery
                if (sysStats != null && sysStats.battery != null) {
                    return sysStats.battery.toNumber().format("%d") + "%";
                }
                return "--%";

            case 1: // Steps
                if (actInfo != null && actInfo.steps != null) {
                    return actInfo.steps.format("%d");
                }
                return "0";

            case 2: // Steps Remaining to Goal
                if (actInfo != null && actInfo.steps != null && actInfo.stepGoal != null) {
                    var rem = actInfo.stepGoal - actInfo.steps;
                    if (rem < 0) {
                        rem = 0;
                    }
                    return rem.format("%d");
                }
                return "--";

            case 3: // Calories
                if (actInfo != null && actInfo.calories != null) {
                    return actInfo.calories.format("%d") + " CAL";
                }
                return "-- CAL";

            case 4: // Distance (ActivityMonitor distance is in cm)
                if (actInfo != null && actInfo.distance != null) {
                    var isStatute = (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE);
                    if (isStatute) {
                        var miles = actInfo.distance.toFloat() / 160934.4f;
                        return miles.format("%.1f") + " MI";
                    } else {
                        var km = actInfo.distance.toFloat() / 100000.0f;
                        return km.format("%.1f") + " KM";
                    }
                }
                return "--";

            case 5: // Heart Rate
                if (hr > 0) {
                    return hr.format("%d") + " BPM";
                }
                return "-- BPM";

            case 6: // None
            default:
                return "";
        }
    }
}
