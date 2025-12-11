import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class RainbowApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new RainbowView()];
    }
}

class RainbowView extends WatchUi.WatchFace {
    private var _background as BitmapResource?;
    private var _timeDigits as Array<BitmapResource>?;
    private var _timeColon as BitmapResource?;
    private var _dateDigits as Array<BitmapResource>?;
    private var _dateDot as BitmapResource?;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        _background = WatchUi.loadResource(Rez.Drawables.Background) as BitmapResource;

        // Load time font digits (80px)
        _timeDigits = [
            WatchUi.loadResource(Rez.Drawables.TimeDigit0) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.TimeDigit1) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.TimeDigit2) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.TimeDigit3) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.TimeDigit4) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.TimeDigit5) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.TimeDigit6) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.TimeDigit7) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.TimeDigit8) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.TimeDigit9) as BitmapResource
        ];
        _timeColon = WatchUi.loadResource(Rez.Drawables.TimeColon) as BitmapResource;

        // Load date font digits (40px)
        _dateDigits = [
            WatchUi.loadResource(Rez.Drawables.DateDigit0) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.DateDigit1) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.DateDigit2) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.DateDigit3) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.DateDigit4) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.DateDigit5) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.DateDigit6) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.DateDigit7) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.DateDigit8) as BitmapResource,
            WatchUi.loadResource(Rez.Drawables.DateDigit9) as BitmapResource
        ];
        _dateDot = WatchUi.loadResource(Rez.Drawables.DateDot) as BitmapResource;
    }

    function onUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        var sec = clockTime.sec;

        // Calculate wobble offsets for background
        var bgWobbleX = (Math.sin(sec * Math.PI / 10.0) * 8).toNumber();
        var bgWobbleY = (Math.cos(sec * Math.PI / 15.0) * 6).toNumber();

        // Calculate wobble offsets for time (slightly different phase)
        var timeWobbleX = (Math.sin((sec + 20) * Math.PI / 12.0) * 6).toNumber();
        var timeWobbleY = (Math.cos((sec + 20) * Math.PI / 18.0) * 4).toNumber();

        // Calculate wobble offsets for date (different phase again)
        var dateWobbleX = (Math.sin((sec + 40) * Math.PI / 8.0) * 5).toNumber();
        var dateWobbleY = (Math.cos((sec + 40) * Math.PI / 12.0) * 3).toNumber();

        // Draw background with wobble, scaled to screen size
        if (_background != null) {
            // Scale background to fill screen, then apply wobble offset
            dc.drawScaledBitmap(bgWobbleX - 4, bgWobbleY - 3, width + 8, height + 6, _background);
        }

        // Draw custom font time with wobble
        var hour = clockTime.hour;
        var min = clockTime.min;
        drawCustomTime(dc, centerX + timeWobbleX, centerY - 20 + timeWobbleY, hour, min);

        // Draw custom font date with wobble (DD.MM format)
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var day = info.day;
        var month = info.month;
        drawCustomDate(dc, centerX + dateWobbleX, centerY + 55 + dateWobbleY, day, month);
    }

    // Draw time using custom bitmap font
    function drawCustomTime(dc as Dc, centerX as Number, centerY as Number, hour as Number, min as Number) as Void {
        if (_timeDigits == null || _timeColon == null) {
            return;
        }

        var spacing = 4;
        var colonSpacing = 2;
        var digitHeight = (_timeDigits[0] as BitmapResource).getHeight();

        var h1 = hour / 10;
        var h2 = hour % 10;
        var m1 = min / 10;
        var m2 = min % 10;

        var w1 = (_timeDigits[h1] as BitmapResource).getWidth();
        var w2 = (_timeDigits[h2] as BitmapResource).getWidth();
        var colonWidth = (_timeColon as BitmapResource).getWidth();
        var w3 = (_timeDigits[m1] as BitmapResource).getWidth();
        var w4 = (_timeDigits[m2] as BitmapResource).getWidth();

        var totalWidth = w1 + w2 + colonWidth + w3 + w4 + spacing * 2 + colonSpacing * 2;
        var startX = centerX - totalWidth / 2;
        var startY = centerY - digitHeight / 2;

        dc.drawBitmap(startX, startY, _timeDigits[h1] as BitmapResource);
        startX += w1 + spacing;
        dc.drawBitmap(startX, startY, _timeDigits[h2] as BitmapResource);
        startX += w2 + colonSpacing;

        var colonHeight = (_timeColon as BitmapResource).getHeight();
        dc.drawBitmap(startX, centerY - colonHeight / 2, _timeColon as BitmapResource);
        startX += colonWidth + colonSpacing;

        dc.drawBitmap(startX, startY, _timeDigits[m1] as BitmapResource);
        startX += w3 + spacing;
        dc.drawBitmap(startX, startY, _timeDigits[m2] as BitmapResource);
    }

    // Draw date using custom bitmap font (DD.MM format)
    function drawCustomDate(dc as Dc, centerX as Number, centerY as Number, day as Number, month as Number) as Void {
        if (_dateDigits == null || _dateDot == null) {
            return;
        }

        var spacing = 2;
        var dotSpacing = 1;
        var digitHeight = (_dateDigits[0] as BitmapResource).getHeight();

        var d1 = day / 10;
        var d2 = day % 10;
        var m1 = month / 10;
        var m2 = month % 10;

        var w1 = (_dateDigits[d1] as BitmapResource).getWidth();
        var w2 = (_dateDigits[d2] as BitmapResource).getWidth();
        var dotWidth = (_dateDot as BitmapResource).getWidth();
        var w3 = (_dateDigits[m1] as BitmapResource).getWidth();
        var w4 = (_dateDigits[m2] as BitmapResource).getWidth();

        var totalWidth = w1 + w2 + dotWidth + w3 + w4 + spacing * 2 + dotSpacing * 2;
        var startX = centerX - totalWidth / 2;
        var startY = centerY - digitHeight / 2;

        dc.drawBitmap(startX, startY, _dateDigits[d1] as BitmapResource);
        startX += w1 + spacing;
        dc.drawBitmap(startX, startY, _dateDigits[d2] as BitmapResource);
        startX += w2 + dotSpacing;

        var dotHeight = (_dateDot as BitmapResource).getHeight();
        dc.drawBitmap(startX, startY + digitHeight - dotHeight - 2, _dateDot as BitmapResource);
        startX += dotWidth + dotSpacing;

        dc.drawBitmap(startX, startY, _dateDigits[m1] as BitmapResource);
        startX += w3 + spacing;
        dc.drawBitmap(startX, startY, _dateDigits[m2] as BitmapResource);
    }

    function onEnterSleep() as Void {
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        WatchUi.requestUpdate();
    }
}
