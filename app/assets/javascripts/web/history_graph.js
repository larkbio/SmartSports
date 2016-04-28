
function determineColor(point) {
    var m = {
        start: "dashboardBgColor",
        health: "healthBgColor",
        medication: "medicationBgColor",
        exercise: "exerciseBgColor",
        wellbeing: "wellbeingBgColor",
        diet: "dietBgColor"
    };
    if($.inArray(point.kind, Object.keys(m)) ) {
        return m[point.kind]
    }
    return "dashboardBgColor";
}

function determineImage(point) {
    var m = {
        start: "startType",
        blood_pressure: "bloodPressureType",
        blood_sugar: "bloodSugarType",
        weight: "weightType",
        cycling: "cyclingType",
        steps: "stepsType",
        insulin: "insulinType",
        drug: "drugType",
        sleep: "sleepType",
        drink: "drinkType",
        food: "foodType",
        calory: "foodType",
        smoke: "smokeType"
    };
    var ret = "";
    if(point['kind']=="exercise") {
        ret = "exerciseType";
    }
    if(m[point.type]!=undefined) {
        ret = m[point.type];
    }
    return ret;
}

function determineTooltip(point) {
    return point['date'] + "<br/>" + point['tooltip'];
}

function convertToHistory(data) {
    var result = [];
    if(data.length == 0) {
        var ret3 = {};
        var d = moment(new Date()).format(moment_datefmt);
        ret3['time'] = d;
        var hmap = {};
        hmap['kind'] = "start";
        hmap['type'] = "start";
        hmap['date'] = d;
        hmap['tooltip'] = "";
        ret3['history'] = [];
        ret3['history'].push(hmap);
        result.push(ret3);
        return result;
    }
    var adata = data.filter(function(d) {return d['evt_type']!= 'waist';});
    var amap = {};
    var k = {};
    adata.map(function (p) {
        return moment(p['dates'][0]).format(moment_datefmt);
    }).forEach( function(it) {
            k[it] = 1;
    });
    Object.keys(k).forEach(function (v) {
        amap[v] = [];
    });
    adata.forEach(function (p) {
        amap[moment(p['dates'][0]).format(moment_datefmt)].push(p);
    });
    var dateKeys = Object.keys(amap);
    dateKeys.sort();
    dateKeys.forEach(function (currKey) {
        var ret = {};
        ret['time'] = currKey;
        ret['history'] = amap[currKey].map(function (aval) {
            var ret2 = {};
            ret2['kind'] = aval['kind'];
            ret2['type'] = aval['evt_type'];
            ret2['tooltip'] = aval['tooltip'];
            ret2['date'] = moment(aval['dates'][0]).format(moment_fmt);
            return ret2;
        });
        ret['history'].sort(function(a,b) {
            if(a['date']==b['date']) return 0;
            if(a['date']<b['date']) return -1;
            return 1;
        });
        result.push(ret);
    });
    return result;
}

function countElements(history) {
    var count = 0;
    jQuery.each(history, function () {

        jQuery.each(this.history, function () {
            count++;
        });
    });
    return count;
}

function getElement(history, a, b) {
    return history[a].history[b];
}

function computeLeft(history, w, a, b) {
    return w/(history.length+1)*(a+1) + b*55 - (history[a].history.length*55)/2;
}

function addPoint(canvas, length, history, a, b) {
    var w = $(canvas).width();
    var left = computeLeft(history, w, a, b);
    var point = getElement(history, a, b);

    return ( b == 0 ? "<div class='historyTime' style='left:"+left+"px'>"+history[a].time+"</div>" : "") +
        "<div class='historyItem " + determineColor(point) +
        "' style='left:" + left + "px'><div class='inner "+
        determineImage(point)+"' title='"+determineTooltip(point)+"'></div></div>";
}

function addPoints(canvas, history) {
    var LENGTH = 10;
    var a = 0;
    var b = 0;
    var lastb = 0;
    var w = $(canvas).width();

    var pointsHTML = "";
    jQuery.each(history, function (dayIdx, day) {
        jQuery.each(day.history, function (itemIdx, item) {
            pointsHTML += addPoint(canvas, LENGTH, history, a, b);
            b++;
        });
        a++;
        lastb = b;
        b = 0;
    });
    var sl = computeLeft(history, w, 0, 0);
    var sw = computeLeft(history, w, a-1, lastb-1);

    pointsHTML = "<div class='historyLine' style='left:"+sl+"px;width:"+(sw-sl)+"px;"+"'></div>"+pointsHTML;

    pointsHTML += "<div style='clear:both;'></div>";
    $(canvas).html(pointsHTML);
    $(canvas+" .inner").qtip();
}
