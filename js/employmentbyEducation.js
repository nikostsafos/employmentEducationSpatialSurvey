(function () {

var contentWidth = document.getElementById('content').clientWidth;

var plotWidth;
  if (contentWidth >= 800) {plotWidth = contentWidth/2;} 
  else if (contentWidth >= 500) {plotWidth = contentWidth;}
  else { plotWidth = contentWidth; }

var plotHeight;
  if (contentWidth >= 800) {plotHeight = 200;} 
  else if (contentWidth >= 500) {plotHeight = 200;} 
  else { plotHeight = 200; }

  var margin = {top: 30, right: 20, bottom: 20, left: 20},
      width = plotWidth - margin.left - margin.right,
      height = plotHeight - margin.top - margin.bottom;

  var x = d3.scaleBand()
            .domain(["0-35", "35-40", "40-45", "45-50", "50-55", "55-60", "60-65", "65-70", "70-75",
                     "75-80", "80-85", "85-90", "90-100"])
            .range([0, width])
            .padding(0.1);
     
  var y = d3.scaleLinear()
            .domain([0, 35])
            .range([height, 0]);

  var color = d3.scaleOrdinal()
                .domain(["Less than high school graduate", 
                         "High school graduate (includes equivalency)",
                         "Some college or associate's degree",
                         "Bachelor's degree or higher"])
                .range(['#8c510a', '#d8b365', '#5ab4ac', '#01665e']);

    d3.csv("data/brackets.csv", type, function(error, data) {
      if (error) throw error;

      var sectors = d3.nest()
          .key(function(d) { return d.Variable; })
          .entries(data);

      var svg = d3.select("#brackets").selectAll("svg")
          .data(sectors)
          .enter().append("svg")
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom)
          .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      svg.selectAll('bar')
         .data(function(d) {return d.values;})
         .enter()
         .append('rect')
         .attr('class', 'bar')
         .attr("x", function(d) { return x(d.Bracket); })
         .attr("y", function(d) { return y(d.Value); })
         .attr("width", x.bandwidth())
         .attr("height", function(d) { return height - y(d.Value); })
         .attr("fill", function(d) {return color(d.Variable)});
            
      svg.append("text")
          .attr("x", width/2)
          .attr("y", -5)
          .attr('text-anchor', 'middle')
          .text(function(d) { return d.key; });

      // Append x axis 
      svg.append("g")
         .attr('class', 'xaxis')
         .attr("transform", "translate(0," + height + ")")
         .call(d3.axisBottom(x)
         // .tickFormat(d3.format(".0f"))
         .tickValues(["0-35", "35-40", "40-45", "45-50", "50-55", "55-60", "60-65", "65-70", "70-75", 
                      "75-80", "80-85", "85-90", "90-100"]));

      // Append y axis
      svg.append("g")
         .attr('class', 'yaxis')
         .call(d3.axisLeft(y)
         .ticks(6));

    })

    function type(d) {
      d.Bracket = d.Bracket;
      d.Variable = d.Variable;
      d.Value = +d.Value;
      return d;
    }
})();