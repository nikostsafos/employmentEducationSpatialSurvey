(function () {

var contentWidth = document.getElementById('content').clientWidth;

var plotWidth;
  if (contentWidth >= 800) {plotWidth = contentWidth;} 
  else if (contentWidth >= 500) {plotWidth = contentWidth;}
  else { plotWidth = contentWidth; }

var plotHeight;
  if (contentWidth >= 800) {plotHeight = contentWidth/1.5;} 
  else if (contentWidth >= 500) {plotHeight = contentWidth/1.5;} 
  else { plotHeight = contentWidth/1.5; }

var margin = {top: 0, right: 0, bottom: 0, left: 0},
    width = plotWidth - margin.left - margin.right,
    height = plotHeight - margin.top - margin.bottom;

 var svg = d3.select('#map')
             .append('svg')
             .attr("width", width + margin.left + margin.right)
             .attr("height", height + margin.top + margin.bottom);

var results = d3.map();

// var projection = d3.geoAlbersUsa()
//                         .scale(500)
//                         .translate([width / 2, height / 2]);

var path = d3.geoPath();//.projection(projection);

var color = d3.scaleOrdinal()
              .domain(['Top 20%', 'Bottom 20%'])
              .range(['#d8b365', '#5ab4ac', '#f0f0f0']);
    
var g = svg.append("g")
           .attr("class", "key")
           .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    g.append("text")
        .attr("class", "caption")
        .attr("x", width/2 - 50)
        .attr("y", -6)
        .attr("fill", "#d8b365")
        .attr("text-anchor", "start")
        .attr("font-weight", "bold")
        .text("Top 20%");

    g.append("text")
        .attr("class", "caption")
        .attr("x", width/2 + 50)
        .attr("y", -6)
        .attr("fill", "#5ab4ac")
        .attr("text-anchor", "start")
        .attr("font-weight", "bold")
        .text("Bottom 20%");

    d3.queue()
        .defer(d3.json, "https://d3js.org/us-10m.v1.json")
        .defer(d3.csv, "data/topbottomMap.csv", function(d) { results.set(d.id, d.Rank); })
        .await(ready);

    function ready(error, us) {
      if (error) throw error;

      svg.append("g")
         .attr("class", "counties")
         .selectAll("path")
         .data(topojson.feature(us, us.objects.counties).features)
         .enter().append("path")
         .attr("fill", function(d) { return color(d.Rank = results.get(d.id)); })
         .attr("d", path);

      svg.append("path")
          .datum(topojson.mesh(us, us.objects.states, function(a, b) { return a !== b; }))
          .attr("class", "states")
          .attr("d", path);
    }
})();