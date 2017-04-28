(function () {

var contentWidth = document.getElementById('content').clientWidth;

var plotWidth;
  if (contentWidth >= 800) {plotWidth = contentWidth/3;} 
  else if (contentWidth >= 500) {plotWidth = contentWidth/2;}
  else { plotWidth = contentWidth; }

var plotHeight;
  if (contentWidth >= 800) {plotHeight = contentWidth/3;} 
  else if (contentWidth >= 500) {plotHeight = contentWidth/3;} 
  else { plotHeight = contentWidth/2; }

  var margin = {top: 30, right: 20, bottom: 20, left: 20},
      width = plotWidth - margin.left - margin.right,
      height = plotHeight - margin.top - margin.bottom;

  var x = d3.scaleLinear()
            .domain([0,100])
            .range([0, width]);

  var y = d3.scaleLinear()
            .domain([0,100])
            .range([height, 0]);

  var color = d3.scaleOrdinal()
                .domain(["Less than high school graduate", 
                         "High school graduate (includes equivalency)",
                         "Some college or associate's degree",
                         "Bachelor's degree or higher"])
                .range(['#8c510a', '#d8b365', '#5ab4ac', '#01665e']);

    d3.csv("data/scatter.csv", type, function(error, data) {
      if (error) throw error;

      var sectors = d3.nest()
          .key(function(d) { return d.Variable; })
          .entries(data);

      var svg = d3.select("#scatterPlot").selectAll("svg")
          .data(sectors)
          .enter().append("svg")
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom)
          .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      svg.selectAll('dot')
         .data(function(d) {return d.values;})
         .enter()
         .append('circle')
         .attr('class', 'dot')
         .attr('cx', function(d) { return x(d.BAorHigher); })
         .attr('cy', function(d) { return y(d.Value); })
         .attr('r', 2.5)
         .style('fill', function (d) {return color(d.Variable)});
            
      svg.append("text")
          .attr("x", width/2)
          .attr("y", -10)
          .attr('text-anchor', 'middle')
          .text(function(d) { return d.key; });

      // svg.append('text')
      //    .attr('transform', 'translate(0,' + height + ')')
      //    .attr('x', width/2)
      //    .attr('y', 0)
      //    .attr('dy', '2.5em')
      //    .style('text-anchor', 'middle')
      //    .text('Emp-Pop Ratio, ages 25-64 (BA or higher)');

      // svg.append('text')
      //    .attr('transform', 'rotate(-90)')
      //    .attr('x', 0)
      //    .attr('y', 0)
      //    .attr('dy', '-2em')
      //    .style('text-anchor', 'end')
      //    .text('Emp-Pop Ratio, aged 25-64, percent');

      // Append x axis 
      svg.append("g")
         .attr('class', 'xaxis')
         .attr("transform", "translate(0," + height + ")")
         .call(d3.axisBottom(x)
         .tickFormat(d3.format(".0f")));

      // Append y axis
      svg.append("g")
         .attr('class', 'yaxis')
         .call(d3.axisLeft(y)
         .ticks(6));
    })

    function type(d) {
      d.id = d.id;
      d.BAorHigher = +d.BAorHigher;
      d.Variable = d.Variable;
      d.Value = +d.Value;
      return d;
    }
})();