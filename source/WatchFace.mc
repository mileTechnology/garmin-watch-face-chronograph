import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// 454x454 AMOLED round display
// Inspired by Tissot chronograph: cream dial, blue tachymetre bezel,
// three charcoal sub-dials, orange center seconds hand

class WatchFaceView extends WatchUi.WatchFace {

    // Color palette
    const WHITE       = 0xFFFFFF;
    const BEZEL_DARK  = 0x222222;  // dark gunmetal bezel
    const CHARCOAL    = 0x1C1C1C;
    const HAND_DARK   = 0x1A1A1A;
    const ORANGE      = 0xFF6600;
    const SILVER      = 0xCCCCCC;
    const DIM_GRAY    = 0x888888;
    const ACCENT_BLUE = 0x1155CC;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;
        var clock = System.getClockTime();
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawBezel(dc, cx, cy);
        drawMainDial(dc, cx, cy);
        drawHourMarkers(dc, cx, cy);
        drawSubDials(dc, cx, cy, clock);
        // Between minute marks 16 and 17 (99° from 12), radius 115
        var dateRad = 99.0 * Math.PI / 180.0;
        var dateX = (cx + 115 * Math.sin(dateRad)).toNumber();
        var dateY = (cy - 115 * Math.cos(dateRad)).toNumber();
        drawDateWindow(dc, dateX, dateY, now.day);

        var hourAngle = ((clock.hour % 12) * 60.0 + clock.min) / 720.0 * 360.0;
        var minAngle  = (clock.min * 60.0 + clock.sec) / 3600.0 * 360.0;
        var secAngle  = clock.sec / 60.0 * 360.0;

        drawHourHand(dc, cx, cy, hourAngle);
        drawMinuteHand(dc, cx, cy, minAngle);
        drawSecondsHand(dc, cx, cy, secAngle);
        drawCenterCap(dc, cx, cy);
    }

    // Dark gunmetal tachymetre bezel with white tick marks
    private function drawBezel(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
        dc.setColor(BEZEL_DARK, BEZEL_DARK);
        dc.fillCircle(cx, cy, 226);

        // Thin silver inner bezel ring
        dc.setColor(SILVER, SILVER);
        dc.setPenWidth(2);
        dc.drawCircle(cx, cy, 207);
        dc.setPenWidth(1);

        // Tachymetre ticks
        dc.setColor(0xFFFFFF, 0xFFFFFF);
        for (var i = 0; i < 60; i++) {
            var rad = i * 6.0 * Math.PI / 180.0;
            var s = Math.sin(rad);
            var c = Math.cos(rad);
            var isMajor = (i % 5 == 0);
            var inner = isMajor ? 210 : 215;
            dc.setPenWidth(isMajor ? 2 : 1);
            dc.drawLine(
                (cx + inner * s).toNumber(), (cy - inner * c).toNumber(),
                (cx + 223 * s).toNumber(),   (cy - 223 * c).toNumber()
            );
        }
        dc.setPenWidth(1);
    }

    // Cream main dial
    private function drawMainDial(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
        dc.setColor(WHITE, WHITE);
        dc.fillCircle(cx, cy, 205);
    }

    // Baton hour markers + minute dots
    private function drawHourMarkers(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
        for (var i = 0; i < 60; i++) {
            var rad = i * 6.0 * Math.PI / 180.0;
            var s = Math.sin(rad);
            var c = Math.cos(rad);
            if (i % 5 == 0) {
                dc.setColor(HAND_DARK, HAND_DARK);
                dc.setPenWidth(6);
                dc.drawLine(
                    (cx + 176 * s).toNumber(), (cy - 176 * c).toNumber(),
                    (cx + 197 * s).toNumber(), (cy - 197 * c).toNumber()
                );
            } else {
                dc.setColor(DIM_GRAY, DIM_GRAY);
                dc.fillCircle(
                    (cx + 189 * s).toNumber(),
                    (cy - 189 * c).toNumber(),
                    2
                );
            }
        }
        dc.setPenWidth(1);
    }

    // Three charcoal sub-dials
    //   Top (12-side): minutes  — with blue accents
    //   Bottom-left:   hours (12h)
    //   Bottom-right:  seconds
    private function drawSubDials(dc as Graphics.Dc, cx as Number, cy as Number, clock as System.ClockTime) as Void {
        var subR = 47;

        // Top: minutes 0-60
        var topX = cx;
        var topY = cy - 85;
        drawSubDial(dc, topX, topY, subR, clock.min, 60, true);
        drawSubDialLabel(dc, topX, topY, subR, "60",   0.0);
        drawSubDialLabel(dc, topX, topY, subR, "20", 120.0);
        drawSubDialLabel(dc, topX, topY, subR, "40", 240.0);

        // Bottom-left: hours 0-12
        var blX = cx - 78;
        var blY = cy + 70;
        drawSubDial(dc, blX, blY, subR, clock.hour % 12, 12, false);
        drawSubDialLabel(dc, blX, blY, subR, "12",   0.0);
        drawSubDialLabel(dc, blX, blY, subR,  "3",  90.0);
        drawSubDialLabel(dc, blX, blY, subR,  "6", 180.0);
        drawSubDialLabel(dc, blX, blY, subR,  "9", 270.0);

        // Bottom-right: seconds 0-60
        var brX = cx + 78;
        var brY = cy + 70;
        drawSubDial(dc, brX, brY, subR, clock.sec, 60, false);
        drawSubDialLabel(dc, brX, brY, subR, "60",   0.0);
        drawSubDialLabel(dc, brX, brY, subR, "20", 120.0);
        drawSubDialLabel(dc, brX, brY, subR, "40", 240.0);
    }

    private function drawSubDialLabel(dc as Graphics.Dc, cx as Number, cy as Number, r as Number, text as String, angleDeg as Float) as Void {
        var rad = angleDeg * Math.PI / 180.0;
        var labelR = r - 19;
        var lx = (cx + labelR * Math.sin(rad)).toNumber();
        var ly = (cy - labelR * Math.cos(rad)).toNumber();
        dc.setColor(SILVER, Graphics.COLOR_TRANSPARENT);
        dc.drawText(lx, ly, Graphics.FONT_XTINY, text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawSubDial(dc as Graphics.Dc, cx as Number, cy as Number, r as Number, value as Number, maxVal as Number, blueAccents as Boolean) as Void {
        // Dark background
        dc.setColor(CHARCOAL, CHARCOAL);
        dc.fillCircle(cx, cy, r);

        // Outer ring
        dc.setColor(DIM_GRAY, DIM_GRAY);
        dc.setPenWidth(1);
        dc.drawCircle(cx, cy, r);

        // Tick marks — blue at 1/3 and 2/3 positions on top sub-dial
        for (var i = 0; i < 12; i++) {
            var rad = i * 30.0 * Math.PI / 180.0;
            var s = Math.sin(rad);
            var c = Math.cos(rad);
            var isMajor = (i % 3 == 0);
            // Blue accents at 20/40 positions (i==4 and i==8) on top sub-dial
            if (blueAccents && (i == 4 || i == 8)) {
                dc.setColor(ACCENT_BLUE, ACCENT_BLUE);
                dc.setPenWidth(3);
            } else {
                dc.setColor(SILVER, SILVER);
                dc.setPenWidth(isMajor ? 2 : 1);
            }
            var inner = isMajor ? r - 10 : r - 6;
            dc.drawLine(
                (cx + inner * s).toNumber(), (cy - inner * c).toNumber(),
                (cx + (r - 2) * s).toNumber(), (cy - (r - 2) * c).toNumber()
            );
        }
        dc.setPenWidth(1);

        // Sub-dial hand
        var angle = value.toFloat() / maxVal.toFloat() * 360.0;
        var rad   = angle * Math.PI / 180.0;
        dc.setColor(SILVER, SILVER);
        dc.setPenWidth(2);
        dc.drawLine(cx, cy,
            (cx + (r - 13) * Math.sin(rad)).toNumber(),
            (cy - (r - 13) * Math.cos(rad)).toNumber()
        );
        dc.setPenWidth(1);

        // Center jewel
        dc.setColor(DIM_GRAY, DIM_GRAY);
        dc.fillCircle(cx, cy, 3);
    }

    // Date window at 3 o'clock
    private function drawDateWindow(dc as Graphics.Dc, x as Number, y as Number, day as Number) as Void {
        dc.setColor(0xFFFFFF, 0xFFFFFF);
        dc.fillRectangle(x - 14, y - 11, 28, 22);
        dc.setColor(0x555555, 0x555555);
        dc.drawRectangle(x - 14, y - 11, 28, 22);
        dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, Graphics.FONT_TINY, day.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Thick tapered hour hand
    private function drawHourHand(dc as Graphics.Dc, cx as Number, cy as Number, angle as Float) as Void {
        var rad = angle * Math.PI / 180.0;
        var s   = Math.sin(rad);
        var c   = Math.cos(rad);
        dc.setColor(HAND_DARK, HAND_DARK);
        dc.setPenWidth(9);
        dc.drawLine(
            (cx - 25 * s).toNumber(), (cy + 25 * c).toNumber(),
            (cx + 108 * s).toNumber(), (cy - 108 * c).toNumber()
        );
        // Luminous center strip (cream)
        dc.setColor(WHITE, WHITE);
        dc.setPenWidth(3);
        dc.drawLine(
            (cx - 20 * s).toNumber(), (cy + 20 * c).toNumber(),
            (cx + 100 * s).toNumber(), (cy - 100 * c).toNumber()
        );
        dc.setPenWidth(1);
    }

    // Long slim minute hand
    private function drawMinuteHand(dc as Graphics.Dc, cx as Number, cy as Number, angle as Float) as Void {
        var rad = angle * Math.PI / 180.0;
        var s   = Math.sin(rad);
        var c   = Math.cos(rad);
        dc.setColor(HAND_DARK, HAND_DARK);
        dc.setPenWidth(7);
        dc.drawLine(
            (cx - 30 * s).toNumber(), (cy + 30 * c).toNumber(),
            (cx + 163 * s).toNumber(), (cy - 163 * c).toNumber()
        );
        // Luminous strip
        dc.setColor(WHITE, WHITE);
        dc.setPenWidth(2);
        dc.drawLine(
            (cx - 25 * s).toNumber(), (cy + 25 * c).toNumber(),
            (cx + 157 * s).toNumber(), (cy - 157 * c).toNumber()
        );
        dc.setPenWidth(1);
    }

    // Orange center seconds sweep with lollipop counterbalance tail
    private function drawSecondsHand(dc as Graphics.Dc, cx as Number, cy as Number, angle as Float) as Void {
        var rad = angle * Math.PI / 180.0;
        var s   = Math.sin(rad);
        var c   = Math.cos(rad);
        dc.setColor(ORANGE, ORANGE);
        dc.setPenWidth(2);
        // Tail stem
        dc.drawLine(cx, cy,
            (cx - 50 * s).toNumber(), (cy + 50 * c).toNumber()
        );
        // Main sweep
        dc.drawLine(cx, cy,
            (cx + 192 * s).toNumber(), (cy - 192 * c).toNumber()
        );
        dc.setPenWidth(1);
        // Lollipop circle at tail end
        var lx = (cx - 50 * s).toNumber();
        var ly = (cy + 50 * c).toNumber();
        dc.fillCircle(lx, ly, 7);
        dc.setColor(CHARCOAL, CHARCOAL);
        dc.fillCircle(lx, ly, 4);  // dark inner to give ring effect
    }

    // Center cap: dark outer, orange inner jewel
    private function drawCenterCap(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
        dc.setColor(HAND_DARK, HAND_DARK);
        dc.fillCircle(cx, cy, 9);
        dc.setColor(ORANGE, ORANGE);
        dc.fillCircle(cx, cy, 4);
    }

    function onPartialUpdate(dc as Graphics.Dc) as Void {
        // Redraw seconds hand each second in always-on mode
        var clock = System.getClockTime();
        var secAngle = clock.sec / 60.0 * 360.0;
        drawSecondsHand(dc, dc.getWidth() / 2, dc.getHeight() / 2, secAngle);
        drawCenterCap(dc, dc.getWidth() / 2, dc.getHeight() / 2);
    }

    function onEnterSleep() as Void {
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        WatchUi.requestUpdate();
    }
}

class WatchFaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return [new WatchFaceView()];
    }
}
