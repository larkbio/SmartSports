function TimelinePlot(uid, resource, date, title, params) {
    this.uid = uid;
    this.resource = resource;
    this.date = date;
    this.title = title;
    if(!params) {
        this.params = {period: "weekly"}
    } else {
        this.params = params;
    }
    this.chartElementSelector = null;
}

TimelinePlot.prototype.draw = function(chartElementSelector) {
    self = this;
    this.chartElementSelector = chartElementSelector;
    this.initUI();

    url = "users/"+this.uid+"/"+this.resource+".json?date="+this.date;
    if(this.params["period"]=="weekly") {
        url = url+"&weekly=true";
    }

    dataReceived = function(jsonData) {
        if(jsonData.length==0) {
            self.showNoData();
        } else {
            data = self.dataAdapter(jsonData);
            window.currdata = data;

            self.initExtents(data);

            self.initCanvas();

            var lines = $.grep(data, function(d) { return d.disp_type=="line"; });
            console.log(lines);
            self.drawLines(lines);

            var points = $.grep(data, function(d) { return d.disp_type=="point"; })
            console.log(points);
            self.drawPoints(points);

            self.initTooltips();
        }
    };
    console.log("making request: "+url);
    d3.json(urlPrefix()+url, dataReceived);
};

TimelinePlot.prototype.getTooltip = function(d) {
    title = d.tooltip;
    if(d.dates.length>1 && d.dates[1]!=null && d.dates[0]!= d.dates[1]) {
        title = title + "<br/>Duration:" + ((d.dates[1] - d.dates[0]) / 60.0 / 1000.0).toFixed(2) + "min";
    }
    title = title +
        "<br/>At: " + moment(d.dates[0]).format("YYYY-MM-DD HH:mm:SS") +
        "<br/>Source: " + d.source;
    return title
};

TimelinePlot.prototype.scaleVal = function(dataPoint, defaultValue, idx) {
    if(idx==undefined) {
        idx = 0;
    }
    var y_scale = self.transforms.other.scale;
    var value = defaultValue;
    if(("values" in dataPoint) && dataPoint.values.length > 0) {
        if(idx>=dataPoint.values.length) {
            value = dataPoint.values[0];
        } else {
            value = dataPoint.values[idx];
        }
        if(dataPoint.kind=="health" && dataPoint.evt_type in self.transforms) {
            y_scale = self.transforms[dataPoint.evt_type].scale;
        }
    }
    return y_scale(value);
};

TimelinePlot.prototype.drawPoints = function(data) {
    var self = this;
    var groups = self.canvas.selectAll("g.pointdata").data(data);
    var groupsEnter = groups.enter().append("g")
        .attr("id", function(d) { return d.id; } )
        .attr("data-tooltip", self.getTooltip)
        .attr("data-titlebar", true)
        .attr("data-title", function(d) {return d.title;})
        .attr("class", "pointdata");

    groupsEnter.append("circle").attr("class", function(d) { return d.kind+" timePoints timePointsA";});
    groupsEnter.append("circle").attr("class", function(d) { return d.kind+" timePointsInner timePointsAInner";});

    groupsEnter.selectAll("circle.timePointsA")
        .attr("cx", function(d) {
            var time_scale = self.transforms.time.scale;
            return time_scale(d.dates[0].getTime());
        })
        .attr("cy", function(d) {
            return self.scaleVal(d, d.depth);
        })
        .attr("r", "5");

    groupsEnter.selectAll("circle.timePointsAInner")
        .attr("cx", function(d) {
            var time_scale = self.transforms.time.scale;
            return time_scale(d.dates[0].getTime());
        })
        .attr("cy", function(d) {
            return self.scaleVal(d, d.depth);
        })
        .attr("r", "2");
};

TimelinePlot.prototype.drawLines = function(data) {
    self = this;
    groups = this.canvas.selectAll("g.linedata").data(data);
    groupsEnter = groups.enter().append("g")
        .attr("id", function(d) { return d.id;})
        .attr("data-tooltip", self.getTooltip  )
        .attr("data-titlebar", 'true')
        .attr("data-title", function(d) {return d.title;})
        .attr("class", "linedata");

    groupsEnter.append("line").attr("class", function(d) { return d.kind+" timeLines";});
    groupsEnter.append("circle").attr("class", function(d) { return d.kind+" timePoints timePointsA";});
    groupsEnter.append("circle").attr("class", function(d) { return d.kind+" timePointsInner timePointsAInner";});
    groupsEnter.append("circle").attr("class", function(d) { return d.kind+" timePoints timePointsB";});
    groupsEnter.append("circle").attr("class", function(d) { return d.kind+" timePointsInner timePointsBInner";});

    var time_scale = self.transforms.time.scale;
    groupsEnter.select("line")
        .attr("x1", function(d){return time_scale(d.dates[0].getTime());})
        .attr("y1", function(d) {return self.scaleVal(d, d.depth);})
        .attr("x2", function(d) {return time_scale(d.dates[1].getTime());})
        .attr("y2", function(d) {return self.scaleVal(d, d.depth, 1);});

    groupsEnter.selectAll("circle.timePointsA")
        .attr("cx", function(d) {return time_scale(d.dates[0].getTime());})
        .attr("cy", function(d) {return self.scaleVal(d, d.depth);})
        .attr("r", "5");

    groupsEnter.selectAll("circle.timePointsAInner")
        .attr("cx", function(d) {return time_scale(d.dates[0].getTime());})
        .attr("cy", function(d) {return self.scaleVal(d, d.depth);})
        .attr("r", "2");

    groupsEnter.selectAll("circle.timePointsB")
        .attr("cx", function(d) {return time_scale(d.dates[1].getTime());})
        .attr("cy", function(d) {return self.scaleVal(d, d.depth, 1);})
        .attr("r", "5");

    groupsEnter.selectAll("circle.timePointsBInner")
        .attr("cx", function(d) {return time_scale(d.dates[1].getTime());})
        .attr("cy", function(d) {return self.scaleVal(d, d.depth, 1);})
        .attr("r", "2");
};

TimelinePlot.prototype.update = function(date) {
    this.date = date;
    this.draw(this.chartElementSelector);
};

TimelinePlot.prototype.updatePeriod = function(period) {
    this.params.period = period;
    this.draw(this.chartElementSelector);
};

TimelinePlot.prototype.dataAdapter = function(data) {
    var result = [];
    var i;
    for(i = 0; i < data.length; ++i ) {
        var d = data[i];
        var dispType = "other";
        var kinds = new Set();
        kinds.add(["exercise", "medication", "diet"]);
        if(kinds.has(d.kind)) {
            dispType = "point";
        } else if(d.kind=="health"){
            dispType = "point";
            if(d.kind=="health"&&d.evt_type=="blood_pressure") {
                // add the pulse measurement as a separate data point
                var pulse = $.extend({}, d);
                pulse["disp_type"] = "point";
                pulse["values"] = [d["values"][2]];
                pulse["dates"] = [new Date(d.dates[0])];
                pulse["meas_type"] = "pulse";
                result.push(pulse);

                // add the original blood pressure as a line measurement
                var origValues = d.values;
                d.values = [origValues[0], origValues[1]];
                dispType = "line";
            }
        } else if(d.kind=="lifestyle") {
            dispType = "line";
        }

        if(d.dates.length>1) {
            d.dates[1] = new Date(d.dates[1]);
        } else {
            d.dates[1] = new Date(d.dates[0]);
        }
        if(d.dates.length>0) {
            d.dates[0] = new Date(d.dates[0]);
        }
        d["disp_type"] = dispType;
        result.push(d);
    }
    return result;
};

TimelinePlot.prototype.showNoData = function() {
    this.svg.append("text")
        .text("No data")
        .attr("class", "warn")
        .attr("x", this.width/2-this.margin.left)
        .attr("y", this.height/2);
};

TimelinePlot.prototype.initUI = function() {
    d3.select(this.chartElementSelector+" svg").remove();

    this.svg = d3.select(this.chartElementSelector).append("svg");
    this.margin = {top: 20, right: 30, bottom: 20, left: 40};
    aspect = 1.0/7.0;

    this.width = $(this.chartElementSelector).width();
    this.height = aspect*this.width;

    this.svg
        .attr("width", this.width)
        .attr("height", this.height);

//    this.setTitle("Weekly chart");

};

TimelinePlot.prototype.initCanvas = function() {
    self.svg.append("clipPath")
        .attr("id", "chart-clip")
        .append("rect")
        .attr("x", 0)
        .attr("y", 0)
        .attr("width", self.width-self.margin.right )
        .attr("height", self.height-self.margin.top);

    var time_axis = d3.svg.axis()
        .scale(self.transforms['time']['scale'])
        .ticks(10);

    self.svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate("+self.margin.left+","+(self.height-self.margin.bottom)+")")
        .call(time_axis);

    self.canvas = self.svg
        .append("g")
        .attr("transform", "translate("+self.margin.left+","+(self.margin.top)+")")
        .attr("clip-path", "url(#chart-clip)");
};

TimelinePlot.prototype.initTooltips = function() {
    $(this.chartElementSelector+' [data-tooltip!=""]').each ( function() {
        $(this).qtip({
            content: {
                title: $(this).attr('data-title'),
                text: $(this).attr('data-tooltip')
            },
            titlebar: {
                attr: 'data-title'
            },
            position: {
                my: 'bottom center',
                at: 'top center',
                viewport: $('#chart-clip')
            },
            style: {
                classes: 'qtip-default qtip qtip-green qtip-shadow qtip-rounded'
            }
        })
    });
};

TimelinePlot.prototype.initExtents = function(data) {
    var time_extent = d3.extent(data, function (d) {
        return d.dates[0];
    });
    if ("period" in this.params && this.params.period == "weekly") {
        time_extent = [moment(this.date).startOf("week"), moment(this.date).endOf("week")];
    } else if("period" in this.params && this.params.period == "daily"){
        time_extent = [moment(this.date).startOf("day"), moment(this.date).endOf("day")];
    }

    var time_scale = d3.time.scale().domain(time_extent).range([0, self.width-self.margin.left-self.margin.right]);

    var y_extent = [0, 10];
    var y_scale = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(y_extent);

    var hr_extent = [20, 200];
    var hr_scale = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(hr_extent);

    var bp_extent = [50, 200];
    var bp_scale = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(bp_extent);

    var bg_extent = [0, 20];
    var bg_scale = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(bg_extent);

    var weight_extent = [1, 200];
    var weight_scale = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(weight_extent);

    var waist_extent = [30, 300];
    var waist_scale = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(weight_extent);

    self.transforms = {
        blood_sugar: {extent: bg_extent, scale: bg_scale},
        blood_pressure: {extent: bp_extent, scale: bp_scale},
        pulse: {extent: hr_extent, scale: hr_scale},
        weight: {extent: weight_extent, scale: weight_scale},
        waist: {extent: waist_extent, scale: waist_scale},
        other: {extent: y_extent, scale: y_scale},
        time: {extent: time_extent, scale: time_scale}
    };
};

TimelinePlot.prototype.setTitle = function(title) {
    $(this.chartElementSelector)[0].parentNode.querySelector(".chartTitle").textContent = title;
};
