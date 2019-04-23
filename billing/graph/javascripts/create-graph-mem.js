/*
 * Parse the data and create a graph with the data.
 */
function parseData(createGraph) {
        Papa.parse("../data/ocp-mem.csv", {
                download: true,
                complete: function(results) {
                        createGraph(results.data);
                }
        });
}

function createGraph(data) {
        var ons = [];
        var mem = [];

        for (var i = 1; i < data.length; i++) {

            if (data[i][2] !== undefined && data[i][2] !== null && data[i][5] !== undefined && data[i][5] !== null) {
               ons.push(data[i][2]);
               mem.push(data[i][5]);
            } else {
               ons.push(0);
               mem.push(0);
            }

        }
        console.log(ons);
        console.log(mem);

        var chart = c3.generate({
                bindto: '#chartmem',
            data: {
                columns: [
                        mem
                ],
                type: 'bar',
                labels: false
            },
            axis: {
                x: {
                    type: 'category',
                    categories: ons,
                    tick: {
                        multiline: true,
                        culling: {
                        max: 15
                        }
                }
                }
            },
            zoom: {
                enabled: true
        },
            legend: {
                show: false
            }
        });
}

parseData(createGraph);
